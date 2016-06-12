//
//  ManualFlashViewController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/14/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreMedia
import SwiftyDropbox

enum Slope {
    case Up , Down, Equal
}


class ManualFlashViewController: UIViewController, CameraAndFlashControllerDelegate {

    @IBOutlet weak var messageInput: UITextField!
    @IBAction func messageSendPressed(sender: UIButton) {
        sendMessage()
    }
    @IBOutlet weak var flashSwitch: UISwitch!
    @IBOutlet weak var flashLevel: UILabel!
    @IBOutlet weak var flashSliderLevel: UISlider!
    @IBOutlet weak var linkToDropboxButton: UIButton!
    @IBAction func flashSwitchChanged(sender: UISwitch) {
        updateFlashState()
      }

    @IBAction func flashLevelChanged(sender: UISlider) {
        updateFlashState()
    }
    @IBAction func readMessagePressed(sender: UIButton) {
        toggleCamera()
    }
    
    @IBOutlet weak var messageRead: UILabel!
    
    @IBOutlet weak var readMessageButton: UIButton!
    
    let flashManager = CameraAndFlashController()
  
    var scanIndex: [Int] = []
    var scanBrightness: [Int] = []
    var scanDelta:[Int] = []
    var scanTime: [Double] = []
    let messageBuffer: MessageBuffer = MessageBuffer()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !flashManager.hasTorch {
            flashSwitch.enabled = false
            flashSwitch.setOn(false, animated: false)
        }
        updateFlashState()
        flashManager.delegate = self

        // Do any additional setup after loading the view.
        
        if Dropbox.authorizedClient != nil {
            linkToDropboxButton.hidden = true;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateFlashState() {
        guard flashManager.hasTorch else {
            flashLevel.text = "not available"
            return
        }
        
        if flashSwitch.on {
            flashManager.setTorchLevel(Double(flashSliderLevel.value))
        } else {
            flashManager.setTorchLevel(0)
        }
        flashLevel.text = "\(Int(flashSliderLevel.value * 100))%"

    }
    
    
    func sendMessage() {
        if let message = messageInput.text {
            print("sending message \(message)")
            let encoder = CharacterEncoder()
            encoder.setMessage(message)
            if let levels = encoder.getFramedMessage() {
                for (i,l) in levels.enumerate() {
                    printDebug("sending message level \(l) for bit \(i)", withTime: true)
                    flashManager.addTorchLevelToQueue(Double(l))
                }
                // turns off at end of message
                flashManager.addTorchLevelToQueue(0)
                
            }
        }
    }
    
    // MARK: - Camera
    func toggleCamera() {
        switch flashManager.readState {
        case .NotReading:
            let configureCompleteAction = { (success: Bool) -> Void in
                if success {
                    self.flashManager.startCamera()  // starts camera and sets up the video session
                    self.readMessageButton.setTitle("Stop", forState: UIControlState.Normal)
                } else {
                    printDebug("can't start video")
                }
            }
            flashManager.configure(configureCompleteAction)
        case .Reading:
            flashManager.stopCamera()
            self.readMessageButton.setTitle("Start", forState: UIControlState.Normal)
            saveScanToDropbox()
            clearScanData()
        }
        
    }
    
    
    func didGetCameraFrame(frame: UIImage, time: CMTime) {
        if let brightness = frame.averageBrightness {
            let slope = addScanDataPoint(Int(brightness), time: time)
            dispatch_async(dispatch_get_main_queue(), {self.messageRead.text = "\(brightness) + \(slope)"})
       }
    }
    
    func addScanDataPoint(brightness: Int, time: CMTime) -> Slope {
        var delta : Slope = .Equal
        if let lastIndex = scanIndex.last, lastScanBrightness = scanBrightness.last {
            scanIndex.append(lastIndex + 1)
            scanDelta.append(brightness - lastScanBrightness)
        } else {
            scanIndex.append(0)
            scanDelta.append(0)
        }
        
        scanBrightness.append(brightness)
        scanTime.append(CMTimeGetSeconds(time))
        if let lastDelta = scanDelta.last {
            switch lastDelta {
            case 40...255:
                delta = .Up
            case -255 ... -40:
                delta = .Down
            default:
                delta = .Equal
            }
        }
        return delta
    }
    
    func clearScanData() {
        scanTime = []
        scanDelta = []
        scanIndex = []
        scanBrightness = []
    }
    
    var scanDataAsCSVString: String {
        var samplesAsCSV = "time,index,brighness,delta\n"
        for (idx,time) in scanTime.enumerate() {
            let row = "\(time), \(scanDelta[idx]), \(scanIndex[idx]), \(scanBrightness[idx]);\n"
            samplesAsCSV = samplesAsCSV + row
        }
       return samplesAsCSV
    }
    
    
    // MARK: - Dropbox
    @IBAction func linkButtonPressed(sender: AnyObject) {
        Dropbox.authorizeFromController(self)
    }
    
    @IBAction func testUpload(sender: AnyObject) {
        //Must have the beginning slash... ugh
        uploadToDropBox("/hello.txt", fileData: "hello!")
    }
    
    func saveScanToDropbox() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        let filePath = "/lt_\(formatter.stringFromDate(NSDate())).csv"
        uploadToDropBox(filePath, fileData: scanDataAsCSVString)
    }
    
    func uploadToDropBox(filePath: String, fileData: String)
    {
        if let client = Dropbox.authorizedClient {
            let encodedFileData = fileData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            client.files.upload(path: filePath, body: encodedFileData!).response { response, error in
                if let metadata = response {
                    print("*** Upload file ****")
                    print("Uploaded file name: \(metadata.name)")
                    print("Uploaded file revision: \(metadata.rev)")
                    
                    // Get file (or folder) metadata
                    client.files.getMetadata(path: "/hello.txt").response { response, error in
                        print("*** Get file metadata ***")
                        if let metadata = response {
                            if let file = metadata as? Files.FileMetadata {
                                print("This is a file with path: \(file.pathLower)")
                                print("File size: \(file.size)")
                            } else if let folder = metadata as? Files.FolderMetadata {
                                print("This is a folder with path: \(folder.pathLower)")
                            }
                        } else {
                            print(error!)
                        }
                    }
                    
                } else {
                    print(error!)
                }
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ManualFlashViewController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/14/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreMedia

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
    @IBAction func flashSwitchChanged(sender: UISwitch) {
        updateFlashState()
      }

    @IBAction func flashLevelChanged(sender: UISlider) {
        updateFlashState()
    }
    @IBAction func readMessagePressed(sender: UIButton) {
        startCamera()
    }
    
    @IBOutlet weak var messageRead: UILabel!
    
    let flashManager = CameraAndFlashController()
    var scanIndex: [Int] = []
    var scanBrightness: [Int] = []
    var scanDelta:[Int] = []
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
    func startCamera() {
        let configureCompleteAction = { (success: Bool) -> Void in
            if success {
                self.flashManager.startCamera()  // starts camera and sets up the video session
            } else {
                printDebug("can't start video")
            }
        }
        flashManager.configure(configureCompleteAction)
    }
    
    
    func didGetCameraFrame(frame: UIImage, time: CMTime) {
        if let brightness = frame.averageBrightness {
            let slope = addScanDataPoint(Int(brightness))
            dispatch_async(dispatch_get_main_queue(), {self.messageRead.text = "\(brightness) + \(slope)"})
       }
    }
    
    func addScanDataPoint(brightness: Int) -> Slope {
        var delta : Slope = .Equal
        if let lastIndex = scanIndex.last, lastScanBrightness = scanBrightness.last {
            scanIndex.append(lastIndex + 1)
            scanDelta.append(brightness - lastScanBrightness)
        } else {
            scanIndex.append(0)
            scanDelta.append(0)
        }
        scanBrightness.append(brightness)
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

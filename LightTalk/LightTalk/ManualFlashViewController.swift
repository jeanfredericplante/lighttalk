//
//  ManualFlashViewController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/14/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ManualFlashViewController: UIViewController {

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
    let flashManager = CameraAndFlashController()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !flashManager.hasTorch {
            flashSwitch.enabled = false
            flashSwitch.setOn(false, animated: false)
        }
        updateFlashState()

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
            if let levels = encoder.getBits() {
                for l in levels {
                    printDebug("sending flash level \(l)", withTime: true)
                    flashManager.setTorchLevel(Double(l))

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

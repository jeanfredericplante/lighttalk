//
//  ManualFlashViewController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/14/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ManualFlashViewController: UIViewController {

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
            flashLevel.text = "not available"
        }
        updateFlashState()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateFlashState() {
        if flashSwitch.on {
            flashManager.setTorchLevel(Double(flashSliderLevel.value))
        } else {
            flashManager.setTorchLevel(0)
        }
        flashLevel.text = "\(Int(flashSliderLevel.value * 100))%"

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

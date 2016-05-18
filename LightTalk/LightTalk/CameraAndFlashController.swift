//
//  CameraAndFlashController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/1/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import AVFoundation

enum FlashLevel: Float {
    case Zero = 0.0, One = 0.25, Two = 0.5, Three = 0.75, Four = 1.0
}


let messageQueueSent = "com.fantasticwhalelabs.messageQueueSent"


class CameraAndFlashController : NSObject {
    
    var cameraWithTorch: AVCaptureDevice?
    var hasTorch: Bool {
        return cameraWithTorch != nil
    }
    private let torchQueue = NSOperationQueue()

    
    override init() {
        super.init()
        cameraWithTorch = getCameraWithTorch()
        
        torchQueue.maxConcurrentOperationCount = 1
        torchQueue.addObserver(self, forKeyPath: "operationCount", options: .New, context: nil)
    }
    
    func getCameraWithTorch() -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        var detectedCamera: AVCaptureDevice?
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if let hasTorch = device.hasTorch where hasTorch {
                    detectedCamera = device as? AVCaptureDevice
                }
            }
        }
        return detectedCamera
    }
    
    
    // Cancel sequence
//     reference in this repo https://github.com/jorgenrh/morse/blob/ceed97b10e79bb1ca83f19535eff9a5f69263171/Morse/TorchGenerator.swift
    func stop() {
        torchQueue.cancelAllOperations()
    }
    
    
    
    func addTorchLevelToQueue(level: Double) {
        
        torchQueue.addOperationWithBlock({
            self.setTorchLevel(level)
            printDebug("change torch level \(level)", withTime: true)
        })
        
    }
    
    func setTorchLevel(level: Double) {
        
        var torchLevel: Float = Float(level)
        torchLevel = min(torchLevel, AVCaptureMaxAvailableTorchLevel)
        
        guard let cameraWithTorch = cameraWithTorch else { return }
               
        do {
            try cameraWithTorch.lockForConfiguration()
            if torchLevel > 0 {
                try cameraWithTorch.setTorchModeOnWithLevel(torchLevel)
            } else {
                cameraWithTorch.torchMode = .Off
            }
            cameraWithTorch.unlockForConfiguration()
            
        } catch let err as NSError {
            print("Error setting torch level:", err.debugDescription)
        }
    }

    // Observe when queue is finished
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let obj = (object as? NSOperationQueue)
        if (obj == self.torchQueue && keyPath! == "operationCount") {
            if obj?.operationCount == 0 {
                print("*** Torch queue finished")
                NSNotificationCenter.defaultCenter().postNotificationName(messageQueueSent, object: self)
            }
        }
    }
}

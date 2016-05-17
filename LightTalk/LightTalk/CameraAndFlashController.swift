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


class CameraAndFlashController {
    
    var cameraWithTorch: AVCaptureDevice?
    var hasTorch: Bool {
        return cameraWithTorch != nil
    }
    private let torchQueue = NSOperationQueue()

    
    init() {
        cameraWithTorch = getCameraWithTorch()
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
    
    
    func addTorchLevelToQueue(level: Double) {
        
        torchQueue.addOperationWithBlock({
            self.setTorchLevel(level)
            printDebug("change torch level", withTime: true)
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


}

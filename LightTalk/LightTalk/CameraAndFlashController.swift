//
//  CameraAndFlashController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/1/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import AVFoundation


class CameraAndFlashController {
    
    var cameraWithTorch: AVCaptureDevice?
    var hasTorch: Bool {
        return cameraWithTorch == nil
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
    
    func setTorchLevel(level: Double, withDurationInMs: Int) {
        
        let durationInSeconds: UInt32 = UInt32(withDurationInMs * 1000)
        
        torchQueue.addOperationWithBlock({
            self.setTorchLevel(level)
            usleep(durationInSeconds)
        })
        
    }
    
    func setTorchLevel(level: Double) {
        
        var torchLevel: Float = Float(level)
        torchLevel = min(torchLevel, AVCaptureMaxAvailableTorchLevel)
        
        guard let cameraWithTorch = cameraWithTorch else { return }
        guard torchLevel > 0  else {
            cameraWithTorch.torchMode = .Off
            return
        }
        
        do {
            try cameraWithTorch.lockForConfiguration()
            try cameraWithTorch.setTorchModeOnWithLevel(torchLevel)
            cameraWithTorch.unlockForConfiguration()
        } catch let err as NSError {
            print("Error setting torch level:", err.debugDescription)
        }
    }


}

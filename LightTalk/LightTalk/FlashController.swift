//
//  FlashController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 4/30/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import AVFoundation


class FlashController {
    
    var torchDevice: AVCaptureDevice?
    var hasTorch: Bool {
        return torchDevice == nil
    }
    
    init() {
        torchDevice = getCameraWithTorch()
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
    
    
    
}

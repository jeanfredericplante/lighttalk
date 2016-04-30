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
        return nil
    }
    
    
    
}

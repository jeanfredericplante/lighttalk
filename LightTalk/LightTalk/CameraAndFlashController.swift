//
//  CameraAndFlashController.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/1/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum FlashLevel: Float {
    case Zero = 0.0, One = 0.25, Two = 0.5, Three = 0.75, Four = 1.0
}


let messageQueueSent = "com.fantasticwhalelabs.messageQueueSent"

protocol CameraAndFlashControllerDelegate {
    func didGetCameraFrame(frame: UIImage)

}


class CameraAndFlashController : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    struct Constants {
        static let pulseDurationInMilliseconds: UInt32 = 40 // ms
        static let quality =  AVCaptureSessionPresetMedium
        static let orientation: AVCaptureDevicePosition = .Back
    }
    
    // Camera variables
    var session =  AVCaptureSession()
    let sessionQueue = dispatch_queue_create("CameraRecorderQueue", DISPATCH_QUEUE_SERIAL)
    let dataFrameQueue = dispatch_queue_create("DataFrameQueue", DISPATCH_QUEUE_SERIAL)
    var delegate : CameraAndFlashControllerDelegate?

    // Torch variables
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
            usleep(Constants.pulseDurationInMilliseconds * 1000)
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
    
    
    // Receiving the message
    func startCamera() {
        if self.session.running == false {
            NSLog("starting camera")
            dispatch_async(sessionQueue) {
                self.setupVideoSession()
                NSLog("about to start the camera preview")
                self.session.startRunning()
                NSLog("camera preview started")
            }
        } else {
            print("starting camera aborted: session already running")
        }
    }
    
    func stopCamera() {
        if self.session.running == true {
            print("stopping camera")
            dispatch_async(sessionQueue) {
                self.session.stopRunning()
                for output in self.session.outputs {
                    if let avFileOutput = output as? AVCaptureFileOutput {
                        self.session.removeOutput(avFileOutput)
                    }
                }
                
            }
        } else {
            print("stopping camera aborted: session not running")
        }
    }
    
    func setupVideoSession() {
        NSLog("starting video session setup")
        // Video session configuration
        
        self.session.beginConfiguration()
        let videoDataOutput = AVCaptureVideoDataOutput()
          if self.session.canAddOutput(videoDataOutput) {
            self.session.addOutput(videoDataOutput)
        } else {
            print("error: couldn't add the video data output to the session")
        }
        // Max duration
        // Video is always capturing 1 extra frame, substract
        // Add the recording delay to be able to trim it after
        let frameDuration = CMTimeMake(1, 24) // time of 1 frame at 24fps
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        videoDataOutput.setSampleBufferDelegate(self, queue: self.dataFrameQueue)
      
        self.session.commitConfiguration()
        NSLog("finishing video session setup")
        
    }
    
    func configure(completion: (successfulInit: Bool) -> Void) {
        NSLog("configuring video recorder")
        // Adds camera to the session
        
        /** Configure complete action typically starts the session
        
        configureCompleteAction = { (success: Bool) -> Void in
            
            if success {
               self.videoRecorder.startCamera()
                // start camera sets up the video session
            } else {
                printDebug("can't start video")
            }
        } **/
        
        self.session = AVCaptureSession()
        dispatch_async(sessionQueue) {
            self.checkDeviceAuthorizationStatus()
            self.session.sessionPreset = Constants.quality
            if self.cameraWithTorch != nil {
                let input: AVCaptureDeviceInput!
                do {
                    input = try AVCaptureDeviceInput(device: self.cameraWithTorch)
                    self.session.addInput(input)
                    dispatch_async(dispatch_get_main_queue(), {completion(successfulInit: true)})
                } catch let error as NSError {
                    print("error adding input device to recorder \(error)")
                }
            } else {
                printDebug("video device not present")
                dispatch_async(dispatch_get_main_queue(),  {completion(successfulInit: false)})
            }
        }
    }

    private func checkDeviceAuthorizationStatus() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            if !granted {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertView(title: "Alert",
                        message: "CustomCamera doesn't have permission to use Camera, please change privacy settings",
                        delegate: self,
                        cancelButtonTitle: "Ok")
                    alert.show()
                });
            }
        });
    }
    
    
    // MARK: - Delegate methods
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let capturedImage : UIImage = imageFromSampleBuffer(sampleBuffer)
        delegate?.didGetCameraFrame(capturedImage)
    }
    
    
    // MARK: - Utilities
}

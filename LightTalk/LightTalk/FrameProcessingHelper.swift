//
//  FrameProcessingHelper.swift
//  LightTalk
//
//  Created by Jean-Frederic Plante on 5/28/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreImage



func averageBrightness(image: UIImage)-> UIImage
{
    
    let context = CIContext(options: nil)
    let convertImage = CIImage(image: image)
    
    let averageFilter = CIFilter(name: "CIAreaAverage")
    averageFilter!.setValue(convertImage , forKey: kCIInputImageKey)
    let processedImage = averageFilter!.outputImage
    let averagedImage = context.createCGImage(processedImage!, fromRect: processedImage!.extent)
    
    let newImage =  UIImage(CGImage: averagedImage)
    
    return newImage
}

func imageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) ->  UIImage {
    let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
    
    // ベースアドレスをロック
    CVPixelBufferLockBaseAddress(imageBuffer, 0)
    
    // 画像データの情報を取得
    let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
    
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    let width = CVPixelBufferGetWidth(imageBuffer)
    let height = CVPixelBufferGetHeight(imageBuffer)
    
    // RGB色空間を作成
    let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
    
    // Bitmap graphic contextを作成
    let bitmapInfo: UInt32 = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue)).rawValue as UInt32
    let Context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
    
    // Quartz imageを作成
    let imageRef = CGBitmapContextCreateImage(Context)
    
    // ベースアドレスをアンロック
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
    
    // UIImageを作成
    let resultImage:  UIImage =  UIImage(CGImage: imageRef!)
    
    return resultImage
}

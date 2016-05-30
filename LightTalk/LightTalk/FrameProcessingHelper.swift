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



func averageBrightness(image: UIImage) -> UInt8?
{
    let imageWidth = Int(image.size.width)
    let imageHeight = Int(image.size.height)
    var hasAlpha: Bool?
    
    let context = CIContext(options: nil)

    guard let im_ci = image.getCIImage(), averageFilter = CIFilter(name: "CIAreaAverage") else {
        return nil
    }
    
    averageFilter.setValue(im_ci , forKey: kCIInputImageKey)
    averageFilter.setValue(CIVector(CGRect: im_ci.extent), forKey: kCIInputExtentKey)

    guard let processedImage = averageFilter.outputImage else {
        return nil
    }
    let averagedImage = context.createCGImage(processedImage, fromRect: processedImage.extent)
    let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(averagedImage))
    let pixelDataPtr = CFDataGetBytePtr(pixelData)
    
    let red = Int(pixelDataPtr[0])
    let green = Int(pixelDataPtr[0+1])
    let blue = Int(pixelDataPtr[0+2])
    let gray = (red + blue + green) / 3

    return UInt8(gray)
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

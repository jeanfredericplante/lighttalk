//
//  UIImage+Extension.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/29/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

extension UIImage {
    func getCIImage() -> CoreImage.CIImage? {
        if let ci_image = self.CIImage  {
            return ci_image
        } else if let cg_image = self.CGImage {
           return CoreImage.CIImage(CGImage: cg_image)
        } else {
            return nil
        }

    }
    
    var averageBrightness: UInt8?
    {
        let context = CIContext(options: nil)
        
        guard let im_ci = self.getCIImage(), averageFilter = CIFilter(name: "CIAreaAverage") else {
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
        let gray = (red + blue + green) / 3 // alternative luminosity calculation 0.21 R + 0.72 G + 0.07 B
        
        return UInt8(gray)
    }
}

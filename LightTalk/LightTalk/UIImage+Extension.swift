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
}

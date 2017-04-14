//
//  UIColor+Image.swift
//  Amble
//
//  Created by Jono Muller on 14/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UIColor {
  func generateImage() -> UIImage? {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    
    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(self.cgColor)
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

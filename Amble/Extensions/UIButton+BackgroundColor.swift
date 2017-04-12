//
//  UIButton+BackgroundColor.swift
//  Amble
//
//  Created by Jono Muller on 12/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UIButton {
  func setBackgroundColor(color: UIColor, forState: UIControlState) {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    
    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(color.cgColor)
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.setBackgroundImage(image, for: forState)
  }
}

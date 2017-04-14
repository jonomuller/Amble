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
    let image = color.generateImage()
    self.setBackgroundImage(image, for: forState)
  }
}

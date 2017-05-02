//
//  UIView+IndicatorView.swift
//  Amble
//
//  Created by Jono Muller on 02/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension UIView {
  func createIndicatorView(width: CGFloat, height: CGFloat) -> NVActivityIndicatorView {
    let spinner = NVActivityIndicatorView(frame: CGRect(x: self.frame.width / 2 - width / 2,
                                                    y: self.frame.height / 2 - height / 2,
                                                    width: width,
                                                    height: height),
                                      type: .ballScaleRippleMultiple,
                                      color: .white,
                                      padding: 10)
    
    spinner.backgroundColor = .flatGreenDark
    spinner.layer.cornerRadius = height / 2
    self.addSubview(spinner)
    
    return spinner
  }
}

//
//  UINavigationController+Transparent.swift
//  Amble
//
//  Created by Jono Muller on 15/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UINavigationController {
  func makeTransparent() {
    self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationBar.shadowImage = UIImage()
    self.navigationBar.isTranslucent = true
    self.view.backgroundColor = UIColor.clear
  }
}

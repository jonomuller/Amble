//
//  UIViewController+RootView.swift
//  Amble
//
//  Created by Jono Muller on 17/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UIViewController {
  func setRootView(to: String) {
    if let window = self.view.window {
      UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
        let enabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        let storyboard = UIStoryboard(name: to, bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        UIView.setAnimationsEnabled(enabled)
      }, completion: nil)
    }
  }
}

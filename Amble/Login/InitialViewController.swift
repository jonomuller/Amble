//
//  InitialViewController.swift
//  Amble
//
//  Created by Jono Muller on 15/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import ChameleonFramework

class InitialViewController: UIViewController {
  
  @IBOutlet var logo: UIImageView!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var registerButotn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.makeTransparent()
    self.view.backgroundColor = GradientColor(.topToBottom,
                                              frame: view.frame,
                                              colors: [.flatGreenDark, .flatForestGreen])
    
    animateLogo()
    self.setCustomBackButton(image: UIImage(named: "back-button"))
  }
}

// MARK: - Private helper functions

private extension InitialViewController {
  
  func animateLogo() {
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
      self.logo.transform = CGAffineTransform(translationX: 0, y: -150)
    }) { (finished) in
      self.loginButton.isHidden = false
      self.registerButotn.isHidden = false
    }
  }
}

//
//  UIViewController+CustomBackButton.swift
//  Amble
//
//  Created by Jono Muller on 15/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UIViewController {
  func setCustomBackButton(image: UIImage?) {
    self.navigationController?.navigationBar.backIndicatorImage = image
    self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationController?.navigationBar.tintColor = .white
  }
}

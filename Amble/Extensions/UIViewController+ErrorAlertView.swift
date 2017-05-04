//
//  UIViewController+ErrorAlertView.swift
//  Amble
//
//  Created by Jono Muller on 03/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UIViewController {
  func displayErrorAlert(error: NSError) {
    let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alertView, animated: true, completion: nil)
  }
}

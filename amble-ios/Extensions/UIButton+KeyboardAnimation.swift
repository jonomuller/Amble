//
//  UIButton+KeyboardAnimation.swift
//  amble-ios
//
//  Created by Jono Muller on 12/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension UIButton {
  func keyboardWillShow(notification: NSNotification) {
    if let keyboardRectBegin = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
      if let keyboardRectEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
        if keyboardRectBegin != keyboardRectEnd {
          let transform = CGAffineTransform(translationX: 0, y: keyboardRectEnd.origin.y - self.frame.height - 20 - self.frame.origin.y)
          transformButton(transform: transform)
        }
      }
    }
  }
  
  func keyboardWillHide() {
    transformButton(transform: CGAffineTransform.identity)
  }
  
  private func transformButton(transform: CGAffineTransform) {
    UIView.animate(withDuration: 0.1, animations: {
      self.transform = transform
    })
  }
}

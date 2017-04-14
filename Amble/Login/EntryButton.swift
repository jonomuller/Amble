//
//  EntryButton.swift
//  Amble
//
//  Created by Jono Muller on 11/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import ChameleonFramework
import NVActivityIndicatorView

class EntryButton: UIButton {
  
  private var originalWidth: CGFloat!
  private var originalText: String?
  var spinner: NVActivityIndicatorView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.originalWidth = frame.width
    self.layer.cornerRadius = frame.height / 2
    self.backgroundColor = .white
    self.alpha = 0.5
    self.tintColor = .flatGreenDark
    self.titleLabel?.font = UIFont(name: "Avenir-Black", size: 23)
    
    spinner = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30),
                                      type: .ballScaleRippleMultiple,
                                      color: .flatGreenDark)
    self.addSubview(spinner)
    
    self.clipsToBounds = true
    self.setBackgroundColor(color: .flatWhiteDark, forState: .highlighted)
  }
  
  /*
   Enum to determine what the width of the frame should be depending
   on the animation
   */
  enum AnimationType {
    case collapse
    case expand
    
    func width(button: EntryButton) -> CGFloat {
      switch self {
      case .collapse:
        return button.frame.height
      case .expand:
        return button.originalWidth
      }
    }
  }
  
  func collapse(completion: ((Bool) -> Void)?) {
    self.isEnabled = false
    self.originalText = self.titleLabel?.text
    self.setTitle("", for: .normal)
    self.superview?.layoutIfNeeded()
    animateFrame(type: .collapse) { (success) in
      self.spinner.frame = CGRect(x: self.frame.width / 2 - self.spinner.frame.width / 2,
                                  y: self.frame.height / 2 - self.spinner.frame.height / 2,
                                  width: self.spinner.frame.width,
                                  height: self.spinner.frame.height)
      self.spinner.startAnimating()
      completion!(true)
    }
  }
  
  func expand(completion: ((Bool) -> Void)?) {
    self.isEnabled = true
    self.spinner.stopAnimating()
    animateFrame(type: .expand) { (success) in
      self.setTitle(self.originalText, for: .normal)
    }
  }
  
  private func animateFrame(type: AnimationType, completion: ((Bool) -> Void)?) {
    let width = type.width(button: self)
    UIView.animate(withDuration: 0.2, animations: {
      self.frame = CGRect(x: self.frame.midX - width / 2,
                          y: self.frame.midY - self.frame.height / 2,
                          width: width,
                          height: self.frame.height)
    }) { (success) in
      completion?(true)
    }
  }
}

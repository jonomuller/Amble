//
//  LoginButton.swift
//  amble-ios
//
//  Created by Jono Muller on 11/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
  
  private var originalWidth: CGFloat!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originalWidth = frame.width
    layer.cornerRadius = frame.height / 2
    backgroundColor = .white
    tintColor = .green
    titleLabel?.font = UIFont(name: "Avenir-Black", size: 23)
  }
  
  enum AnimationType {
    case collapse
    case expand
    
    func width(button: LoginButton) -> CGFloat {
      switch self {
      case .collapse:
        return button.frame.height
      case .expand:
        return button.originalWidth
      }
    }
  }
  
  func collapse(spinner: UIActivityIndicatorView, completion: ((Bool) -> Void)?) {
    animateFrame(type: .collapse) { (success) in
      spinner.frame = CGRect(x: 26.5 - spinner.frame.width / 2, y: 26.5 - spinner.frame.height / 2, width: spinner.frame.width, height: spinner.frame.height)
      //      spinner.center = CGPoint(x: self.loginButton.frame.midX, y: self.loginButton.frame.midY)
      spinner.color = .green
      
      self.addSubview(spinner)
      spinner.startAnimating()
      
      completion!(true)
    }
  }
  
  func expand(spinner: UIActivityIndicatorView, completion: ((Bool) -> Void)?) {
    spinner.stopAnimating()
    animateFrame(type: .expand, completion: nil)
  }
  
  private func animateFrame(type: AnimationType, completion: ((Bool) -> Void)?) {
    let width = type.width(button: self)
    
    UIView.animate(withDuration: 0.2, animations: {
      self.frame = CGRect(x: self.frame.midX - width / 2,
                          y: self.frame.midY - self.frame.height / 2,
                          width: width,
                          height: self.frame.height)
    }) { (success) in
      if completion != nil {
        completion!(true)
      }
    }
  }
}

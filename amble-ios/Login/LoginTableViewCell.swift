//
//  LoginTableViewCell.swift
//  amble-ios
//
//  Created by Jono Muller on 08/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {
  
  @IBOutlet var innerView: UIView!
  @IBOutlet var textField: UITextField!
  var line: CALayer!
  
  /*
   Enum to adjust the colour and thickness of the bottom line of a UITableViewCell
   */
  enum Selection {
    case select
    case deselect
    
    var color: CGColor {
      switch self {
      case .select:
        return UIColor.white.cgColor
      case .deselect:
        return UIColor.flatWhite.cgColor
      }
    }
    
    var height: CGFloat {
      switch self {
      case .select:
        return CGFloat(2.0)
      case .deselect:
        return CGFloat(1.0)
      }
    }
  }
  
  func updateBottomLine(selection: Selection) {
    let height = selection.height
    self.line.frame = CGRect(x: self.innerView.frame.origin.x, y: self.innerView.frame.size.height - height, width: self.innerView.frame.size.width, height: height)
    self.line.borderColor = selection.color
    self.line.borderWidth = height
  }
  
  func setTextFieldImage(name: String) {
    let image = UIImage(named: name)
    let imageView = UIImageView(image: image)
    let padding = CGRect(x: 0, y: 0, width: imageView.frame.width + 15, height: imageView.frame.height)
    let paddingView = UIView(frame: padding)
    paddingView.addSubview(imageView)
    self.textField.leftView = paddingView
    self.textField.leftViewMode = .always
  }
}

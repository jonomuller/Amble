//
//  EntryTableViewCell.swift
//  Amble
//
//  Created by Jono Muller on 08/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
  
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
    self.line.frame = CGRect(x: self.innerView.frame.origin.x,
                             y: self.innerView.frame.size.height - height,
                             width: self.innerView.frame.size.width,
                             height: height)
    self.line.borderColor = selection.color
    self.line.borderWidth = height
  }
  
  func setTextFieldImage(name: String) {
    let image = UIImage(named: name)
    let imageView = UIImageView(image: image)
    setTextFieldLeftViewWithPadding(view: imageView)
  }
  
  func setTextFieldImageFromText(text: String, size: CGFloat) {
    let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
    label.font = UIFont(name: "Avenir-Black", size: size)
    label.textColor = .white
    label.text = text
    let view = UIView(frame: label.frame)
    view.bounds = CGRect(x: -2, y: 0, width: view.frame.width, height: view.frame.height)
    view.addSubview(label)
    setTextFieldLeftViewWithPadding(view: view)
  }
  
  private func setTextFieldLeftViewWithPadding(view: UIView) {
    let padding = CGRect(x: 0, y: 0, width: view.frame.width + 15, height: view.frame.height)
    let paddingView = UIView(frame: padding)
    paddingView.addSubview(view)
    self.textField.leftView = paddingView
    self.textField.leftViewMode = .always
  }
}

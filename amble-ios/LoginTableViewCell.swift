//
//  LoginTableViewCell.swift
//  amble-ios
//
//  Created by Jono Muller on 08/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {
  
  @IBOutlet var textField: UITextField!
  var line: CALayer!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let height = CGFloat(1.0)
    line = CALayer()
    line.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
    line.borderColor = UIColor.darkGray.cgColor
    line.borderWidth = height
    self.layer.addSublayer(line)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}

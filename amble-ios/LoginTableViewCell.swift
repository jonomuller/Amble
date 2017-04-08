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
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}

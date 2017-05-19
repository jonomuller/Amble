//
//  ReceivedInviteTableViewCell.swift
//  Amble
//
//  Created by Jono Muller on 16/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class ReceivedInviteTableViewCell: InviteTableViewCell {
  
  @IBOutlet var acceptButton: UIButton!
  @IBOutlet var declineButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    acceptButton.layer.cornerRadius = acceptButton.frame.height / 2
    declineButton.layer.cornerRadius = declineButton.frame.height / 2
    
    acceptButton.clipsToBounds = true
    declineButton.clipsToBounds = true
    
    acceptButton.setBackgroundColor(color: .flatForestGreen, forState: .highlighted)
    declineButton.setBackgroundColor(color: .flatRedDark, forState: .highlighted)
  }
  
}

//
//  SentInviteTableViewCell.swift
//  Amble
//
//  Created by Jono Muller on 16/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class SentInviteTableViewCell: UITableViewCell {
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var acceptedLabel: UILabel!
  @IBOutlet var startWalkButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    startWalkButton.layer.cornerRadius = startWalkButton.frame.height / 2
    startWalkButton.clipsToBounds = true
    startWalkButton.setBackgroundColor(color: .flatForestGreen, forState: .highlighted)
  }
  
}

//
//  StatsView.swift
//  Amble
//
//  Created by Jono Muller on 26/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class StatsView: UIView {
  
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var calorieLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setSeparatorLinesInStatsView(width: 1.0)
  }
  
  private func setSeparatorLinesInStatsView(width: CGFloat) {
    let viewWidth = self.frame.width
    var xPos = viewWidth / 3
    let yPos: CGFloat = 12.5
    while xPos < viewWidth {
      let line = UIView(frame: CGRect(x: xPos - width / 2,
                                      y: yPos,
                                      width: width,
                                      height: self.frame.height - yPos * 2))
      line.backgroundColor = .white
      self.addSubview(line)
      xPos += xPos
    }
  }
}

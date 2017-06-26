//
//  Double+String.swift
//  Amble
//
//  Created by Jono Muller on 09/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

extension Double {
  func distanceLabelText() -> NSAttributedString {
    let PREFERRED_DISTANCE_UNIT = "PreferredDistanceUnit"
    
    var distance: Double = 0
    var unitValue: String = ""
    if let unit = UserDefaults.standard.object(forKey: PREFERRED_DISTANCE_UNIT) as? String {
      unitValue = unit
      if unit == "mi" {
        distance = self / 1609.34
      } else if unit == "km" {
        distance = self / 1000.0
      }
    } else {
      distance = self / 1000.0
      unitValue = "km"
      UserDefaults.standard.set("km", forKey: PREFERRED_DISTANCE_UNIT)
    }
    
    let distanceString = String(format: "%.2f %@", distance, unitValue)
    let attributes = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16) as Any]
    let range = NSString(string: distanceString).range(of: String(format: " %@", unitValue))
    let distanceText = NSMutableAttributedString(string: distanceString)
    distanceText.addAttributes(attributes, range: range)
    
    return distanceText
  }
}

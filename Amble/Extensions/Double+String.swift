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
    // Displays distance in km
    // Note: implement option to user miles in future
    let distanceString = String(format: "%.2f km", self / 1000.0)
    let attributes = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16) as Any]
    let range = NSString(string: distanceString).range(of: " km")
    let distanceText = NSMutableAttributedString(string: distanceString)
    distanceText.addAttributes(attributes, range: range)
    
    return distanceText
  }
}

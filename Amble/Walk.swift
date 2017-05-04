//
//  Walk.swift
//  Amble
//
//  Created by Jono Muller on 26/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation
import CoreLocation

struct Walk {
  
  let name: String
  let coordinates: [CLLocationCoordinate2D]
  let time: Int
  let distance: Double
  let steps: Int
  
}

struct WalkInfo {
  
  let id: String
  let name: String
  let image: String
  let date: Date
  
}

//
//  WalkPin.swift
//  Amble
//
//  Created by Jono Muller on 21/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import MapKit

class WalkPin: MKPointAnnotation {
  
  let type: String
  let imageName: String
  
  init(type: String) {
    self.type = type
    self.imageName = type + "_pin"
  }
  
  
}

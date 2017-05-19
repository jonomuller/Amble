//
//  WalkPin.swift
//  Amble
//
//  Created by Jono Muller on 21/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import MapKit

class WalkPin: MKPointAnnotation {
  
  let imageName: String
  
  init(type: String) {
    self.imageName = type + "_pin"
    super.init()
    self.title = type.capitalized
  }
}

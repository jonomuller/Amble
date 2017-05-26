//
//  PlaquePin.swift
//  Amble
//
//  Created by Jono Muller on 26/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import MapKit

class PlaquePin: MKPointAnnotation {
  
  let plaque: Plaque
  
  init(plaque: Plaque) {
    self.plaque = plaque
    super.init()
    self.title = plaque.title
  }

}

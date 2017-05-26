//
//  Plaque.swift
//  Amble
//
//  Created by Jono Muller on 25/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import CoreLocation

struct Plaque {
  
  let id: String
  let coordinate: CLLocationCoordinate2D
  var title: String?
  var inscription: String?
  var imageURL: String?
  
}

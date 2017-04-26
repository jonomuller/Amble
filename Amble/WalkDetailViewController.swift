//
//  WalkDetailViewController.swift
//  Amble
//
//  Created by Jono Muller on 26/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import MapKit

class WalkDetailViewController: UIViewController {
  
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var statsView: StatsView!
  
  var walkID: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

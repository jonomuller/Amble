//
//  WalkDetailViewController.swift
//  Amble
//
//  Created by Jono Muller on 26/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class WalkDetailViewController: WalkViewController {
  
  var walkID: String?
  var walk: Walk?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.barTintColor = .flatGreenDark
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.hidesNavigationBarHairline = true
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    
    if walk == nil {
      self.getWalk()
    } else {
      self.setupView()
    }
  }
}

// MARK: - Action methods

extension WalkDetailViewController {
  func doneButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - Private helper methods

private extension WalkDetailViewController {

  func returnIfNoIDPassed() {
    // Dismiss view controller if no ID is passed
    if walkID == nil {
      let noIDAlertView = UIAlertController(title: "Display error",
                                            message: "No walk ID has been given",
                                            preferredStyle: .alert)
      
      noIDAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        self.dismiss(animated: true, completion: nil)
      }))
      
      self.present(noIDAlertView, animated: true, completion: nil)
    }
  }
  
  func getWalk() {
    self.returnIfNoIDPassed()
    
    APIManager.sharedInstance.getWalk(id: walkID!) { (response) in
      switch response {
      case .success(let json):
        print("Successfully retrieved walk")
        print(json)
        let points = json["walk"]["geometry"]["coordinates"].arrayObject as! [[Double]]
        var coordinates: [CLLocationCoordinate2D] = []
        
        for point in points {
          coordinates.append(CLLocationCoordinate2D(latitude: point[1], longitude: point[0]))
        }
        
        self.walk = Walk(name: json["walk"]["name"].stringValue,
                         coordinates: coordinates,
                         time: json["walk"]["time"].intValue,
                         distance: json["walk"]["distance"].doubleValue,
                         calories: json["walk"]["steps"].doubleValue)
        
        self.setupView()
      case .failure(let error):
        let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
      }
    }
  }
  
  func setupView() {
    self.navigationItem.title = walk?.name
    statsView.timeLabel.text = self.getTimeLabelText(time: (walk?.time)!)
    statsView.distanceLabel.attributedText = self.getDistanceLabelText(distance: (walk?.distance)!)
    
    let polyLine = MKPolyline(coordinates: (walk?.coordinates)!, count: (walk?.coordinates.count)!)
    mapView.add(polyLine)
    mapView.setVisibleMapRect(polyLine.boundingMapRect,
                              edgePadding: UIEdgeInsetsMake(75, 75, 75, 75),
                              animated: true)
    
    self.dropPin(coordinate: (walk?.coordinates.first)!, name: "start")
    self.dropPin(coordinate: (walk?.coordinates.last)!, name: "finish")
  }
}

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

class WalkDetailViewController: UIViewController {
  
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var statsView: StatsView!
  
  var walkID: String?
  var walk: Walk?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if walk == nil {
      self.getWalk()
    } else {
      self.addMapOverlays()
    }
  }
}

// MARK: - Map view delegate

extension WalkDetailViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
      polyLineRenderer.strokeColor = .flatForestGreen
      polyLineRenderer.lineWidth = 5
      return polyLineRenderer
    }
    
    return MKPolylineRenderer()
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let pin = annotation as? WalkPin {
      let pinID = pin.imageName
      if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID) {
        annotationView.annotation = annotation
        return annotationView
      } else {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pinID)
        annotationView.image = UIImage(named: pinID)
        return annotationView
      }
    }
    
    return nil
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
        
        self.walk = Walk(name: json["name"].stringValue,
                         coordinates: coordinates,
                         time: 0,
                         distance: 0,
                         calories: 0)
        
        self.addMapOverlays()
      case .failure(let error):
        let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
      }
    }
  }
  
  func addMapOverlays() {
    let polyLine = MKPolyline(coordinates: (walk?.coordinates)!, count: (walk?.coordinates.count)!)
    mapView.add(polyLine)
    mapView.setVisibleMapRect(polyLine.boundingMapRect,
                              edgePadding: UIEdgeInsetsMake(50, 50, 50, 50),
                              animated: true)
    self.dropPin(coordinate: (walk?.coordinates.first)!, name: "start")
    self.dropPin(coordinate: (walk?.coordinates.last)!, name: "finish")
  }
  
  func dropPin(coordinate: CLLocationCoordinate2D, name: String) {
    let pin = WalkPin(type: name)
    pin.coordinate = coordinate
    mapView.addAnnotation(pin)
  }
}

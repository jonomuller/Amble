//
//  WalkViewController.swift
//  Amble
//
//  Created by Jono Muller on 27/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import MapKit

class WalkViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// MARK: - Map view delegate

extension WalkViewController: MKMapViewDelegate {
  
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

// MARK: - Public helper methods

extension WalkViewController {
  
  func getTimeLabelText(time: Int) -> String {
    let hours = time / 3600
    let minutes = (time / 60) % 60
    let seconds = time % 60
    var timeText = String(format: "%02i:%02i", minutes, seconds)
    
    if hours > 0 {
      timeText = String(format: "%02i:", hours) + timeText
    }
    
    return timeText
  }
  
  func getDistanceLabelText(distance: Double) -> NSAttributedString {
    // Displays distance in km
    // Note: implement option to user miles in future
    let distanceString = String(format: "%.2f km", distance / 1000.0)
    let attributes = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16) as Any]
    let range = NSString(string: distanceString).range(of: " km")
    let distanceText = NSMutableAttributedString(string: distanceString)
    distanceText.addAttributes(attributes, range: range)
    
    return distanceText
  }
}

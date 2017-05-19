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
  
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var statsView: StatsView!
  
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
      var view: MKAnnotationView
      
      if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID) {
        view = annotationView
        view.annotation = annotation
      } else {
        view = MKAnnotationView(annotation: annotation, reuseIdentifier: pinID)
        view.image = UIImage(named: pinID)
      }

      view.canShowCallout = true
      return view
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
  
  func dropPin(coordinate: CLLocationCoordinate2D, name: String) {
    let pin = WalkPin(type: name)
    pin.coordinate = coordinate
    mapView.addAnnotation(pin)
  }
}

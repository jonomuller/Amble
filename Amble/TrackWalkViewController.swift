//
//  TrackWalkViewController.swift
//  Amble
//
//  Created by Jono Muller on 17/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrackWalkViewController: UIViewController {
  
  @IBOutlet var mapView: MKMapView!
  fileprivate var locationManager: CLLocationManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let locationButton = MKUserTrackingBarButtonItem(mapView:self.mapView)
    self.navigationItem.leftBarButtonItem = locationButton
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    // Sets background location tracking
    // Note: should be set when user starts tracking a walk instead of viewDidLoad()
    // Note: need to add a user preference for this in the future
    locationManager.allowsBackgroundLocationUpdates = true
    
    requestLocation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      startTracking()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - Location manager delegate

extension TrackWalkViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      startTracking()
    } else if status == .denied {
      print("Denied")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations[0].coordinate)
  }
}

// MARK: - Private helper methods

private extension TrackWalkViewController {
  
  func displayLocationError() {
    let alert = UIAlertController(title: "Location services are disabled",
                                  message: "Please enable location services in the Settings app in order to track your walks.",
                                  preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
      if let url = URL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }))
    
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func requestLocation() {
    let status = CLLocationManager.authorizationStatus()
    
    // Request user's location, if permission is denied then display error
    if status == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    } else if status == .denied {
      displayLocationError()
    }
  }
  
  func startTracking() {
    locationManager.startUpdatingLocation()
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .follow
  }
}

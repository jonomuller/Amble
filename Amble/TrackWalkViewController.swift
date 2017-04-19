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
  @IBOutlet var statsView: UIView!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var calorieLabel: UILabel!
  
  fileprivate let TIME_INTERVAL = 1.0
  
  fileprivate var locationManager: CLLocationManager!
  fileprivate var locations: [CLLocation] = []
  fileprivate var timer = Timer()
  fileprivate var walkStarted = false
  fileprivate var time = 0
  fileprivate var distance = 0.0
  fileprivate var calories = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.hidesNavigationBarHairline = true
    
    let locationButton = MKUserTrackingBarButtonItem(mapView:self.mapView)
    self.navigationItem.leftBarButtonItem = locationButton
    
    let startButton = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startButtonPressed))
    self.navigationItem.rightBarButtonItem = startButton
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    // Ask for permission to use location if first
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    let status = CLLocationManager.authorizationStatus()
    
    if status == .authorizedWhenInUse {
      self.startTracking()
    } else if status == .denied {
      mapView.userTrackingMode = .none
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
    for location in locations {
      if self.locations.count > 0 {
        distance += location.distance(from: self.locations.last!)
      }
      
      self.locations.append(location)
    }
  }
}

// MARK: - Map view delegate

extension TrackWalkViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    if CLLocationManager.authorizationStatus() == .denied {
      mapView.userTrackingMode = .none
      
      if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
        self.displayLocationError()
      }
    }
  }
}

// MARK: - Button methods

extension TrackWalkViewController {
  
  func startButtonPressed() {
    if CLLocationManager.authorizationStatus() == .denied {
      self.displayLocationError()
      return
    }
    
    if walkStarted {
      // Stop walk
      
      self.navigationItem.rightBarButtonItem?.title = "Start"
      locationManager.allowsBackgroundLocationUpdates = false
      transformStatsView(transform: .identity)
      timer.invalidate()
    } else {
      // Start walk
      
      self.navigationItem.rightBarButtonItem?.title = "Stop"
      
      // Sets background location tracking
      // Note: need to add a user preference for this in the future
      locationManager.allowsBackgroundLocationUpdates = true
      
      transformStatsView(transform: CGAffineTransform(translationX: 0, y: statsView.frame.height))
      time = 0
      distance = 0.0
      calories = 0.0
      timeLabel.text = "00:00"
      timer = Timer.scheduledTimer(timeInterval: TIME_INTERVAL,
                                   target: self,
                                   selector: #selector(timerTick),
                                   userInfo: nil,
                                   repeats: true)
    }
    
    walkStarted = !walkStarted
  }
  
  func timerTick() {
    time += 1
    let hours = time / 3600
    let minutes = (time / 60) % 60
    let seconds = time % 60
    var timeText = String(format: "%02i:%02i", minutes, seconds)
    
    if hours > 0 {
      timeText = String(format: "%02i:", hours) + timeText
    }
    
    timeLabel.text = timeText
    distanceLabel.text = String(format: "%.2f", distance / 1000.0)
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
  
  func startTracking() {
    locationManager.startUpdatingLocation()
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .follow
  }
  
  func transformStatsView(transform: CGAffineTransform) {
    UIView.animate(withDuration: 0.3) { 
      self.statsView.transform = transform
    }
  }
}

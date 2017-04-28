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

class TrackWalkViewController: WalkViewController {
  
  fileprivate let TIME_INTERVAL = 1.0
  
  fileprivate var locationManager: CLLocationManager!
  fileprivate var locations: [CLLocation] = []
  fileprivate var nameAlert: UIAlertController!
  fileprivate var saveWalkAction: UIAlertAction!
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
    // We do not need to update locations if the walk has not started
    if !walkStarted {
      return
    }
    
    for location in locations {
      // Ignore location if it is not accurate to 10 metres
      if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 10 {
        return
      }
      
      if self.locations.count > 0 {
        // Draw line on map as the user moves
        let points = [self.locations.last!.coordinate, location.coordinate]
        let polyLine = MKPolyline(coordinates: points, count: points.count)
        mapView.add(polyLine)
        
        // Increment total distance value
        distance += location.distance(from: self.locations.last!)
      } else {
        self.dropPin(coordinate: location.coordinate, name: "start")
      }
      
      self.locations.append(location)
    }
  }
}

// MARK: - Map view delegate

extension TrackWalkViewController {
  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    if CLLocationManager.authorizationStatus() == .denied {
      mapView.userTrackingMode = .none
      
      if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
        self.displayLocationError()
      }
    }
  }
}

// MARK: - Text field delegate

extension TrackWalkViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.saveWalk(name: textField.text!)
    self.dismiss(animated: true, completion: nil)
    return false
  }
}

// MARK: - Action methods

extension TrackWalkViewController {
  
  func startButtonPressed() {
    if CLLocationManager.authorizationStatus() == .denied {
      self.displayLocationError()
      return
    }
    
    if walkStarted {
      // End walk
      
      let confirmEndAlert = UIAlertController(title: "End Walk", message: nil, preferredStyle: .actionSheet)
      confirmEndAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      
      confirmEndAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
        self.showSaveWalkAlert()
      }))
      
      confirmEndAlert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (action) in
        self.endWalk()
        self.removeMapOverlays()
      }))
      
      self.present(confirmEndAlert, animated: true, completion: nil)
    } else {
      // Start walk
      
      self.navigationItem.rightBarButtonItem?.title = "End"
      
      // Sets background location tracking
      // Note: need to add a user preference for this in the future
      locationManager.allowsBackgroundLocationUpdates = true
      
      transformStatsView(transform: CGAffineTransform(translationX: 0, y: statsView.frame.height))
      locations = []
      time = 0
      distance = 0.0
      calories = 0.0
      statsView.timeLabel.text = "00:00"
      statsView.distanceLabel.attributedText = self.getDistanceLabelText(distance: 0)
      statsView.calorieLabel.text = "0"
      timer = Timer.scheduledTimer(timeInterval: TIME_INTERVAL,
                                   target: self,
                                   selector: #selector(timerTick),
                                   userInfo: nil,
                                   repeats: true)
      
      walkStarted = !walkStarted
    }
  }
  
  func timerTick() {
    time += 1
    statsView.timeLabel.text = self.getTimeLabelText(time: time)
    statsView.distanceLabel.attributedText = self.getDistanceLabelText(distance: distance)
  }
  
  func textFieldDidChange(_ sender: Any) {
    let textField = sender as! UITextField
    saveWalkAction.isEnabled = !(textField.text?.isEmpty)!
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
      self.mapView.layoutMargins = UIEdgeInsets(top: transform.ty, left: 0, bottom: 0, right: 0)
    }
  }
  
  func endWalk() {
    if let location = self.locations.last {
      self.dropPin(coordinate: location.coordinate, name: "finish")
    }
    
    self.navigationItem.rightBarButtonItem?.title = "Start"
    self.transformStatsView(transform: .identity)
    locationManager.allowsBackgroundLocationUpdates = false
    walkStarted = !walkStarted
    timer.invalidate()
  }
  
  func showSaveWalkAlert() {
    if locations.count < 2 {
      let shortWalkErrorView = UIAlertController(title: "Walk too short", message: "Please walk further to save your walk.", preferredStyle: .alert)
      shortWalkErrorView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(shortWalkErrorView, animated: true, completion: nil)
      return
    }
    
    self.endWalk()
    
    nameAlert = UIAlertController(title: "Save Walk",
                                      message: "Please enter a name for the walk",
                                      preferredStyle: .alert)
    
    nameAlert.addTextField(configurationHandler: { (field) in
      field.delegate = self
      field.returnKeyType = .done
      field.enablesReturnKeyAutomatically = true
      field.placeholder = "walk name"
      field.autocapitalizationType = .words
      field.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    })
    
    nameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
      self.removeMapOverlays()
    }))
    
    saveWalkAction = UIAlertAction(title: "Save", style: .default) { (action) in
      if let name = self.nameAlert.textFields?[0].text {
        self.saveWalk(name: name)
      }
    }
    
    saveWalkAction.isEnabled = false
    nameAlert.addAction(saveWalkAction)
    self.present(nameAlert, animated: true, completion: nil)
    
  }
  
  func saveWalk(name: String) {
    APIManager.sharedInstance.createWalk(name: name, owner: User.sharedInstance.userInfo!.id, locations: locations, time: time, distance: distance, steps: calories, completion: { (response) in
      switch response {
      case .success(let json):
        self.removeMapOverlays()
        var coordinates: [CLLocationCoordinate2D] = []
        
        for location in self.locations {
          coordinates.append(location.coordinate)
        }
        
        let walk = Walk(name: json["walk"]["name"].stringValue,
                        coordinates: coordinates,
                        time: self.time,
                        distance: self.distance,
                        calories: self.calories)
        
        self.presentWalkDetailView(walk: walk, id: json["walk"]["_id"].stringValue)
      case .failure(let error):
        let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
          self.present(self.nameAlert, animated: true, completion: nil)
        }))
        
        self.present(alertView, animated: true, completion: nil)
      }
    })
  }
  
  func removeMapOverlays() {
    self.mapView.removeOverlays(self.mapView.overlays)
    self.mapView.removeAnnotations(self.mapView.annotations)
  }
  
  func presentWalkDetailView(walk: Walk, id: String) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "WalkDetailViewController") as! WalkDetailViewController
    vc.walk = walk
    vc.walkID = id
    let navController = UINavigationController(rootViewController: vc)
    self.present(navController, animated: true, completion: nil)
  }
}

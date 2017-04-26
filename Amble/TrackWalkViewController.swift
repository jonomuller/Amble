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
  @IBOutlet var statsView: StatsView!
  
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
        self.dropPin(location: location, name: "start")
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
      statsView.distanceLabel.attributedText = self.getDistanceLabel(distance: 0)
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
    let hours = time / 3600
    let minutes = (time / 60) % 60
    let seconds = time % 60
    var timeText = String(format: "%02i:%02i", minutes, seconds)
    
    if hours > 0 {
      timeText = String(format: "%02i:", hours) + timeText
    }
    
    statsView.timeLabel.text = timeText
    statsView.distanceLabel.attributedText = self.getDistanceLabel(distance: distance)
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
  
  func getDistanceLabel(distance: Double) -> NSAttributedString {
    let distanceString = String(format: "%.2f km", distance / 1000.0)
    let attributes = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16) as Any]
    let range = NSString(string: distanceString).range(of: " km")
    let distanceText = NSMutableAttributedString(string: distanceString)
    distanceText.addAttributes(attributes, range: range)
    
    return distanceText
  }
  
  func dropPin(location: CLLocation, name: String) {
    let pin = WalkPin(type: name)
    pin.coordinate = location.coordinate
    mapView.addAnnotation(pin)
  }
  
  func endWalk() {
    if let location = self.locations.last {
      self.dropPin(location: location, name: "finish")
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
      field.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
      field.returnKeyType = .done
      field.enablesReturnKeyAutomatically = true
      field.placeholder = "walk name"
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
    APIManager.sharedInstance.createWalk(name: name, owner: User.sharedInstance.userInfo!.id, locations: self.locations, completion: { (response) in
      switch response {
      case .success(let json):
        self.removeMapOverlays()
        var coordinates: [CLLocationCoordinate2D] = []
        
        for location in self.locations {
          coordinates.append(location.coordinate)
        }
        
        let walk = Walk(name: json["name"].stringValue,
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

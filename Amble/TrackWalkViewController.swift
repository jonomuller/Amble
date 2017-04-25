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
    
    self.setSeparatorLinesInStatsView(width: 1.0)
    distanceLabel.attributedText = self.getDistanceLabel(distance: 0)
    
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
      let pinID = "pin"
      if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID) {
        annotationView.annotation = annotation
        return annotationView
      } else {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pinID)
        annotationView.image = UIImage(named: pin.imageName)
        return annotationView
      }
    }
    
    return nil
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
      
      if let location = self.locations.last {
        self.dropPin(location: location, name: "finish")
      }
      
      self.navigationItem.rightBarButtonItem?.title = "Start"
      locationManager.allowsBackgroundLocationUpdates = false
      transformStatsView(transform: .identity)
      timer.invalidate()
      
      let nameAlert = UIAlertController(title: "Save Walk",
                                        message: "Please enter a name for the walk",
                                        preferredStyle: .alert)
      
      nameAlert.addTextField(configurationHandler: { (field) in
        field.returnKeyType = .done
        field.enablesReturnKeyAutomatically = true
        field.placeholder = "walk name"
      })
      
      nameAlert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (action) in
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
      }))
      
      let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
        if let name = nameAlert.textFields?[0].text {
          APIManager.sharedInstance.createWalk(name: name, owner: User.sharedInstance.userInfo!.id, locations: self.locations, completion: { (response) in
            switch response {
            case .success(let json):
              print("Successfully saved walk")
              print(json)
              self.mapView.removeOverlays(self.mapView.overlays)
              self.mapView.removeAnnotations(self.mapView.annotations)
              // Display walk detail controller (not implemented yet)
            case .failure(let error):
              let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
              alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              self.present(alertView, animated: true, completion: nil)
            }
          })
        }
      })
      
      nameAlert.addAction(saveAction)
      self.present(nameAlert, animated: true, completion: nil)
      
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
    distanceLabel.attributedText = self.getDistanceLabel(distance: distance)
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
  
  func setSeparatorLinesInStatsView(width: CGFloat) {
    let viewWidth = statsView.frame.width
    var xPos = viewWidth / 3
    let yPos: CGFloat = 12.5
    while xPos < viewWidth {
      let line = UIView(frame: CGRect(x: xPos - width / 2,
                                      y: yPos,
                                      width: width,
                                      height: statsView.frame.height - yPos * 2))
      line.backgroundColor = .white
      statsView.addSubview(line)
      xPos += xPos
    }
  }
  
  func dropPin(location: CLLocation, name: String) {
    let pin = WalkPin(type: name)
    pin.coordinate = location.coordinate
    mapView.addAnnotation(pin)
  }
}

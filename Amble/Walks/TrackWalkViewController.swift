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
import CoreMotion
import NVActivityIndicatorView
import SwiftyJSON

class TrackWalkViewController: WalkViewController {
  
  fileprivate let TIME_INTERVAL = 1.0
  fileprivate let LOCATION_ERROR_TITLE = "Location services are disabled"
  fileprivate let LOCATION_ERROR_MESSAGE = "Please enable location services in the Settings app in order to track your walks."
  fileprivate let LAST_USE_DATE_KEY = "LastUseDate"
  fileprivate let STREAK_COUNT_KEY = "StreakCount"
  
  @IBOutlet var toolbar: UIToolbar!
  fileprivate var spinner: NVActivityIndicatorView!
  
  fileprivate var pedometer: CMPedometer!
  fileprivate var locationManager: CLLocationManager!
  fileprivate var locations: [CLLocation] = []
  var members: [String]?
  
  fileprivate var nameAlert: UIAlertController!
  fileprivate var saveWalkAction: UIAlertAction!
  
  fileprivate var timer = Timer()
  var walkStarted = false
  
  fileprivate var time = 0
  fileprivate var distance = 0.0
  fileprivate var steps = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.hidesNavigationBarHairline = true
    
    let locationButton = MKUserTrackingBarButtonItem(mapView: self.mapView)
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    toolbar.frame = CGRect(x: toolbar.frame.origin.x + 10,
                           y: toolbar.frame.origin.y - 10,
                           width: 44,
                           height: 44)
    
    toolbar.layer.borderColor = UIColor.flatGreenDark.cgColor
    toolbar.layer.borderWidth = 0.5
    toolbar.layer.cornerRadius = 5
    toolbar.clipsToBounds = true
    toolbar.items = [flexibleSpace, locationButton, flexibleSpace]
    
    let startButton = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startButtonPressed))
    self.navigationItem.rightBarButtonItem = startButton
    
    pedometer = CMPedometer()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    // Ask for permission to use location the first time the app is opened
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    
    // Set up spinner loading view to display when walk is being saved
    spinner = self.mapView.createIndicatorView(width: 50, height: 50)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    let status = CLLocationManager.authorizationStatus()
    
    if status == .authorizedWhenInUse {
      self.startTracking()
    } else if status == .denied {
      mapView.userTrackingMode = .none
    }
    
    if walkStarted {
      self.startWalk()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - Location manager delegate

extension TrackWalkViewController: CLLocationManagerDelegate {
  
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
        self.displayPrivacyError(title: LOCATION_ERROR_TITLE, message: LOCATION_ERROR_MESSAGE)
      }
    }
  }
  
  override func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let pin = annotation as? PlaquePin {
      let pinID = pin.plaque.id
      var view: MKAnnotationView
      
      if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID) {
        view = annotationView
        view.annotation = annotation
      } else {
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        DispatchQueue.global().async {
          do {
            if let url = URL(string: pin.plaque.imageURL!) {
              let plaqueImage = try UIImage(data: Data(contentsOf: url))
              let imageView = UIImageView(image: plaqueImage)
              imageView.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
              DispatchQueue.main.async(execute: {
                view.leftCalloutAccessoryView = imageView
              })
            }
          } catch {
            print("Error fetching photo")
          }
        }
      }
      
      view.canShowCallout = true
      return view
    } else {
      return super.mapView(mapView, viewFor: annotation)
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
      self.displayPrivacyError(title: LOCATION_ERROR_TITLE, message: LOCATION_ERROR_MESSAGE)
      return
    }
    
    if walkStarted {
      // End walk
      
      print("Pitch: \(self.mapView.camera.pitch)")
      print("Altitude: \(self.mapView.camera.altitude)")
      print("Heading: \(self.mapView.camera.heading)")
      
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
      self.startWalk()
      walkStarted = true
    }
  }
  
  func timerTick() {
    DispatchQueue.main.async {
      self.statsView.timeLabel.text = self.getTimeLabelText(time: self.time)
      self.statsView.distanceLabel.attributedText = self.distance.distanceLabelText()
    }
    
    // Search for new places every 30 seconds
    if time % 30 == 0 {
      self.searchForPlaques()
    }
    
    time += 1
  }
  
  func textFieldDidChange(_ sender: Any) {
    let textField = sender as! UITextField
    saveWalkAction.isEnabled = !(textField.text?.isEmpty)!
  }
}

// MARK: - Private helper methods

private extension TrackWalkViewController {
  
  func displayPrivacyError(title: String, message: String) {
    let alert = UIAlertController(title: title,
                                  message: message,
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
  
  func startWalk() {
    // Start walk
    
    self.navigationItem.rightBarButtonItem?.title = "End"
    
    // Sets background location tracking
    // Note: need to add a user preference for this in the future
    locationManager.allowsBackgroundLocationUpdates = true
    
    //      let camera = MKMapCamera(lookingAtCenter: self.mapView.userLocation.coordinate,
    //                               fromDistance: 200,
    //                               pitch: 80,
    //                               heading: 0)
    let camera = MKMapCamera()
    camera.centerCoordinate = self.mapView.userLocation.coordinate
    camera.pitch = 63
    camera.altitude = 300
    camera.heading = 0
    self.mapView.setCamera(camera, animated: false)
    self.mapView.userTrackingMode = .followWithHeading
    
    transformStatsView(transform: CGAffineTransform(translationX: 0, y: statsView.frame.height))
    locations = []
    time = 0
    distance = 0.0
    steps = 0
    statsView.timeLabel.text = "00:00"
    statsView.distanceLabel.attributedText = Double(0).distanceLabelText()
    statsView.stepsLabel.text = "0"
    
    // Receive updates from phone's motion data to count number of steps
    if CMPedometer.isStepCountingAvailable() {
      pedometer.startUpdates(from: Date(), withHandler: { (data, error) in
        if let error = error, error._code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
          self.displayPrivacyError(title: "Motion activity is disabled",
                                   message: "Please enable motion activity in the Settings app in order to count your steps.")
          DispatchQueue.main.async(execute: {
            self.statsView.stepsLabel.text = "-"
          })
        } else {
          self.steps = (data?.numberOfSteps.intValue)!
          DispatchQueue.main.async(execute: {
            self.statsView.stepsLabel.text = String(self.steps)
          })
        }
      })
    }
    
    timer = Timer.scheduledTimer(timeInterval: TIME_INTERVAL,
                                 target: self,
                                 selector: #selector(timerTick),
                                 userInfo: nil,
                                 repeats: true)
  }
  
  func endWalk() {
    if let location = self.locations.last {
      self.dropPin(coordinate: location.coordinate, name: "finish")
    }
    
    let camera = MKMapCamera(lookingAtCenter: self.mapView.userLocation.coordinate,
                             fromDistance: 1000,
                             pitch: 0,
                             heading: 0)
    self.mapView.setCamera(camera, animated: false)
    self.mapView.userTrackingMode = .follow
    
    self.navigationItem.rightBarButtonItem?.title = "Start"
    self.transformStatsView(transform: .identity)
    
    locationManager.allowsBackgroundLocationUpdates = false
    pedometer.stopUpdates()
    walkStarted = false
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
      field.autocapitalizationType = .sentences
      field.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    })
    
    nameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
      self.removeMapOverlays()
      self.locations = []
    }))
    
    saveWalkAction = UIAlertAction(title: "Save", style: .default) { (action) in
      if let name = self.nameAlert.textFields?[0].text {
        self.spinner.startAnimating()
        self.saveWalk(name: name)
      }
    }
    
    saveWalkAction.isEnabled = false
    nameAlert.addAction(saveWalkAction)
    self.present(self.nameAlert, animated: true, completion: nil)
  }
  
  func saveWalk(name: String) {
    self.renderMapImage { (image) in
      if let mapImage = image {
        let achievements = self.generateAchivements()
        APIManager.sharedInstance.createWalk(name: name, members: self.members, locations: self.locations, achievements: achievements, image: mapImage, time: self.time, distance: self.distance, steps: self.steps, completion: { (response) in
          self.spinner.stopAnimating()
          
          switch response {
          case .success(let json):
            self.removeMapOverlays()
            
            let coordinates = self.convertToCoordinates()
            self.locations = []
            self.members = nil
            
            let walk = Walk(name: json["walk"]["name"].stringValue,
                            coordinates: coordinates,
                            time: self.time,
                            distance: self.distance,
                            steps: self.steps,
                            achievements: achievements)
            
            self.presentWalkDetailView(walk: walk, id: json["walk"]["_id"].stringValue)
          case .failure(let error):
            let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
              self.present(self.nameAlert, animated: true, completion: nil)
            }))
            
            self.present(alertView, animated: true, completion: nil)
          }
        })
      } else {
        print("Unable to render image")
      }
    }
  }
  
  func convertToCoordinates() -> [CLLocationCoordinate2D] {
    var coordinates: [CLLocationCoordinate2D] = []
    
    for location in self.locations {
      coordinates.append(location.coordinate)
    }
    
    return coordinates
  }
  
  func renderMapImage(completion: @escaping (UIImage?) -> Void) {
    var image: UIImage?
    let snapshotOptions = MKMapSnapshotOptions()
    let coordinates = convertToCoordinates()
    let size = CGSize(width: 200, height: 200)
    let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
    var region = MKCoordinateRegionForMapRect(polyLine.boundingMapRect)
    region.span.latitudeDelta *= 1.2
    region.span.longitudeDelta *= 1.2
    
    snapshotOptions.region = region
    snapshotOptions.scale = UIScreen.main.scale
    snapshotOptions.size = size
    snapshotOptions.showsBuildings = true
    snapshotOptions.showsPointsOfInterest = true
    
    let snapShotter = MKMapSnapshotter(options: snapshotOptions)
    
    snapShotter.start { (snapshot, error) in
      if snapshot != nil {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        snapshot?.image.draw(at: .zero)
        
        if let context = UIGraphicsGetCurrentContext() {
          
          // Draw walk route
          context.setLineWidth(5.0)
          context.setStrokeColor(UIColor.flatForestGreen.cgColor)
          
          var points: [CGPoint] = []
          for coordinate in coordinates {
            points.append((snapshot?.point(for: coordinate))!)
          }
          
          context.addLines(between: points)
          context.strokePath()
          
          // Draw start and finish pins
          for annotation in self.mapView.annotations {
            if let pin = annotation as? WalkPin {
              var point = (snapshot?.point(for: pin.coordinate))!
              let pinImage = UIImage(named: pin.imageName)
              point.x -= (pinImage?.size.width)! / 2
              point.y -= (pinImage?.size.height)! / 2
              pinImage?.draw(at: point)
            }
          }
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        completion(image)
      }
    }
  }
  
  func removeMapOverlays() {
    self.mapView.removeOverlays(self.mapView.overlays)
    self.mapView.removeAnnotations(self.mapView.annotations)
  }
  
  func generateAchivements() -> [Achievement] {
    var achievements: [Achievement] = []
    
    // Create distance achievement
    achievements.append(Achievement(type: .distance, value: Int(self.distance / 10)))
    
    let userDefaults = UserDefaults.standard
    
    // Check if there is a day streak achievement
    if let lastUseDate: Date = userDefaults.object(forKey: LAST_USE_DATE_KEY) as? Date {
      var streakCount = userDefaults.integer(forKey: STREAK_COUNT_KEY)
      let components = Calendar.current.dateComponents([.day], from: lastUseDate, to: Date())
      
      if components.day == 1 {
        streakCount += 1
        userDefaults.set(Date(), forKey: LAST_USE_DATE_KEY)
        userDefaults.set(streakCount, forKey: STREAK_COUNT_KEY)
        achievements.append(Achievement(type: .dayStreak, value: streakCount * 100))
      } else if components.day! > 1 {
        resetDayStreak(userDefaults: userDefaults)
      }
    } else {
      resetDayStreak(userDefaults: userDefaults)
    }
    
    // Check if there is a group achievement
    if let members = members {
      achievements.append(Achievement(type: .group, value: members.count * 100))
    }
    
    return achievements
  }
  
  func resetDayStreak(userDefaults: UserDefaults) {
    userDefaults.set(Date(), forKey: LAST_USE_DATE_KEY)
    userDefaults.set(1, forKey: STREAK_COUNT_KEY)
  }
  
  func presentWalkDetailView(walk: Walk, id: String) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "WalkDetailViewController") as! WalkDetailViewController
    let navController = UINavigationController(rootViewController: vc)
    vc.walk = walk
    vc.walkID = id
    navController.navigationBar.isTranslucent = false
    navController.navigationBar.barTintColor = .flatGreenDark
    navController.navigationBar.tintColor = .white
    navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    navController.navigationBar.isTranslucent = false
    navController.hidesNavigationBarHairline = true
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: vc, action: #selector(vc.doneButtonPressed))
    self.present(navController, animated: true, completion: nil)
  }
  
  func mapRect(for region: MKCoordinateRegion) -> MKMapRect {
    let topLeft = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2.0), longitude: region.center.longitude - (region.span.longitudeDelta/2.0)))
    
    let bottomRight = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2.0), longitude: region.center.longitude + (region.span.longitudeDelta/2.0)))
    
    let origin = MKMapPointMake(min(topLeft.x, bottomRight.x), min(topLeft.y, bottomRight.y))
    let size = MKMapSize(width: fabs(bottomRight.x - topLeft.x),
                         height: fabs(bottomRight.y - topLeft.y))
    
    return MKMapRect(origin: origin, size: size)
  }
  
  func searchForPlaques() {
    let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 500.0, 500.0)
    let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2.0), longitude: region.center.longitude - (region.span.longitudeDelta/2.0))
    let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2.0), longitude: region.center.longitude + (region.span.longitudeDelta/2.0))
    
    let mapRect = self.mapRect(for: region)
    
    APIManager.sharedInstance.searchForPlaques(between: topLeft, and: bottomRight) { (response) in
      switch response {
      case .success(let json):
        var plaques: [Plaque] = []
        for (_, subJson): (String, JSON) in json {
          var plaque = Plaque(id: subJson["id"].stringValue,
                              coordinate: CLLocationCoordinate2D(latitude: subJson["latitude"].doubleValue,
                                                                 longitude: subJson["longitude"].doubleValue),
                              title: nil,
                              inscription: nil,
                              imageURL: nil)
          
          plaques.append(plaque)
        }
        self.displaySearchResults(for: plaques, mapRect: mapRect)
      case .failure(let error):
        self.displayErrorAlert(error: error)
      }
    }
  }
  
  func displaySearchResults(for plaques: [Plaque], mapRect: MKMapRect) {
    if (!walkStarted) {
      return
    }
    
    // Remove pins not close to user
    for annotation in self.mapView.annotations where !(annotation is WalkPin) {
      if !(MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(annotation.coordinate))) {
        DispatchQueue.main.async(execute: {
          self.mapView.removeAnnotation(annotation)
        })
      }
    }
    
    var pins: [MKAnnotation] = []
    
    // Add new pins if they have not already been added
    DispatchQueue.global().async {
      for plaque in plaques {
        if self.isItemAlreadyOnMap(plaque: plaque) {
          continue
        }
        
        APIManager.sharedInstance.getPlaque(id: plaque.id, completion: { (response) in
          switch response {
          case .success(let json):
            var newPlaque = plaque
            newPlaque.title = json["title"].stringValue
            newPlaque.inscription = json["inscription"].stringValue
            if json["photographed?"].boolValue {
              newPlaque.imageURL = json["thumbnail_url"].stringValue
            }
            
            let pin = PlaquePin(plaque: newPlaque)
            pin.coordinate = newPlaque.coordinate
            DispatchQueue.main.async(execute: {
              self.mapView.addAnnotation(pin)
            })
//            pins.append(pin)
          case .failure(let error):
            print("Could not get plaque detail")
          }
        })
      }
      
//      DispatchQueue.main.async(execute: {
//        self.mapView.addAnnotations(pins)
//      })
    }
  }
  
  func isItemAlreadyOnMap(plaque: Plaque) -> Bool {
    var alreadyOnMap = false
    
    for annotation in self.mapView.annotations where !(annotation is WalkPin) {
      if plaque.coordinate.latitude == annotation.coordinate.latitude && plaque.coordinate.longitude == annotation.coordinate.longitude {
        alreadyOnMap = true
      }
    }
    
    return alreadyOnMap
  }
}

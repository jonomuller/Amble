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
  
  @IBOutlet var tableView: UITableView!
  
  var walkID: String?
  var walk: Walk?
  
  fileprivate let ACHIEVEMENT_CELL_IDENTIFIER = "AchievementCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if walk == nil {
      self.getWalk()
    } else {
      self.setupView()
    }
  }
}

// MARK: - Table view data source

extension WalkDetailViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let walk = walk {
      return walk.achievements.count + 1
    }
    
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ACHIEVEMENT_CELL_IDENTIFIER, for: indexPath)
    
    if let walk = walk {
      if indexPath.row == walk.achievements.count {
        var totalPoints = 0
        for achievement in walk.achievements {
          totalPoints += achievement.value
        }
        
        let boldFont = UIFont.boldSystemFont(ofSize: 17.0)
        cell.textLabel?.font = boldFont
        cell.detailTextLabel?.font = boldFont
        cell.textLabel?.text = "Total"
        cell.detailTextLabel?.text = "+\(totalPoints)"
      } else {
        let achievement = walk.achievements[indexPath.row]
        cell.textLabel?.text = achievement.description
        cell.detailTextLabel?.text = "+\(achievement.value)"
      }
    }
    
    return cell
  }
}

// MARK: - Action methods

extension WalkDetailViewController {
  
  func doneButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func deleteButtonPressed() {
    // Display confirmation message to delete walk
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Delete Walk", style: .destructive, handler: { (action) in
      self.deleteWalk()
    }))
    self.present(alert, animated: true, completion: nil)
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
        let points = json["walk"]["geometry"]["coordinates"].arrayObject as! [[Double]]
        var coordinates: [CLLocationCoordinate2D] = []
        
        for point in points {
          coordinates.append(CLLocationCoordinate2D(latitude: point[1], longitude: point[0]))
        }
        
        let achievementsDict = json["walk"]["achievements"].arrayObject as! [[String: Any]]
        var achievements: [Achievement] = []
        
        for achievement in achievementsDict {
          achievements.append(Achievement(type: AchievementType(rawValue: achievement["name"] as! String)!, value: achievement["value"] as! Int))
        }
        
        self.walk = Walk(name: json["walk"]["name"].stringValue,
                         coordinates: coordinates,
                         time: json["walk"]["time"].intValue,
                         distance: json["walk"]["distance"].doubleValue,
                         steps: json["walk"]["steps"].intValue,
                         achievements: achievements)
        
        self.setupView()
      case .failure(let error):
        self.displayErrorAlert(error: error)
      }
    }
  }
  
  func setupView() {
    tableView.reloadData()
    self.navigationItem.title = walk?.name
    statsView.timeLabel.text = self.getTimeLabelText(time: (walk?.time)!)
    statsView.distanceLabel.attributedText = walk?.distance.distanceLabelText()
    statsView.stepsLabel.text = String((walk?.steps)!)
    
    let polyLine = MKPolyline(coordinates: (walk?.coordinates)!, count: (walk?.coordinates.count)!)
    mapView.add(polyLine)
    mapView.setVisibleMapRect(polyLine.boundingMapRect,
                              edgePadding: UIEdgeInsetsMake(20, 20, 20, 20),
                              animated: true)
    
    self.dropPin(coordinate: (walk?.coordinates.first)!, name: "start")
    self.dropPin(coordinate: (walk?.coordinates.last)!, name: "finish")
  }
  
  func deleteWalk() {
    if let id = walkID {
      APIManager.sharedInstance.deleteWalk(id: id, completion: { (response) in
        switch response {
        case .success:
          if let viewControllers = self.navigationController?.viewControllers {
            if viewControllers.count > 1 && viewControllers[viewControllers.count - 2] is ProfileViewController {
              self.navigationController?.popViewController(animated: true)
            } else {
              self.dismiss(animated: true, completion: nil)
            }
          }
        case .failure(let error):
          self.displayErrorAlert(error: error)
        }
      })
    }
  }
}

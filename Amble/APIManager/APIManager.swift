//
//  APIManager.swift
//  Amble
//
//  Created by Jono Muller on 03/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class APIManager: NSObject {
  
  public static let sharedInstance = APIManager()
  
}

// MARK: - Amble API calls

extension APIManager {

  // MARK: /auth
  
  public func login(username: String, password: String, deviceToken: String? = nil, completion: @escaping (APIResponse) -> Void) {
    var details = ["username": username, "password": password]
    
    if let token = deviceToken {
      details["deviceToken"] = token
    }
    
    self.request(router: AmbleRouter.login(details: details)) { (response) in
      completion(response)
    }
  }
  
  public func register(username: String, email: String, password: String, firstName: String, lastName: String, deviceToken: String? = nil, completion: @escaping (APIResponse) -> Void) {
    var details = ["username": username,
                   "email": email,
                   "password": password,
                   "firstName": firstName,
                   "lastName": lastName]
    
    if let token = deviceToken {
      details["deviceToken"] = token
    }
    
    self.request(router: AmbleRouter.register(details: details)) { (response) in
      completion(response)
    }
  }
  
  // MARK: /walks
  
  public func createWalk(name: String, members: [String]?, locations: [CLLocation], achievements: [Achievement], image: UIImage, time: Int, distance: Double, steps: Int, completion: @escaping (APIResponse) -> Void) {
    
    self.request(router: AmbleRouter.getMapImageURL) { (response) in
      switch response {
      case .success(let json):
        let url = json["url"].stringValue
        if let imageData = UIImageJPEGRepresentation(image, 1) {
          self.upload(data: imageData, to: url, headers: ["Content-Type":"image/jpeg"], completion: { (uploadResponse) in
            switch uploadResponse {
            case .success:
              // Create walk
              let imageURL = url.components(separatedBy: "?")[0]
              self.createWalk(name: name, members: members, locations: locations, achievements: achievements, image: imageURL, time: time, distance: distance, steps: steps, completion: { (createResponse) in
                completion(createResponse)
              })
            case .failure:
              completion(uploadResponse)
            }
          })
        }
      case .failure:
        completion(response)
      }
    }
  }
  
  public func getWalk(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.getWalk(id: id)) { (response) in
      completion(response)
    }
  }
  
  public func deleteWalk(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.deleteWalk(id: id)) { (response) in
      completion(response)
    }
  }
  
  // MARK: /users
  
  public func getInfo(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.getInfo(id: id)) { (response) in
      completion(response)
    }
  }
  
  public func getWalks(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.getWalks(id: id)) { (response) in
      completion(response)
    }
  }
  
  public func searchForUser(info: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.userSearch(info: info)) { (response) in
      completion(response)
    }
  }
  
  public func registerToken(token: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.registerToken(token: token)) { (response) in
      completion(response)
    }
  }
  
  public func invite(ids: [String], date: Date, completion: @escaping (APIResponse) -> Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
    
    let details = ["users": ids.description, "date": dateFormatter.string(from: date)]
    
    self.request(router: AmbleRouter.invite(details: details)) { (response) in
      completion(response)
    }
  }
  
  public func getSentInvites(completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.getSentInvites) { (response) in
      completion(response)
    }
  }
  
  public func getReceivedInvites(completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.getReceivedInvites) { (response) in
      completion(response)
    }
  }
  
  // MARK: /invites
  
  public func acceptInvite(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.acceptInvite(id: id)) { (response) in
      completion(response)
    }
  }
  
  public func declineInvite(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.declineInvite(id: id)) { (response) in
      completion(response)
    }
  }
  
  public func startWalk(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: AmbleRouter.startWalk(id: id)) { (response) in
      completion(response)
    }
  }
}

// MARK: - Plaque API calls

extension APIManager {
  
  public func getPlaque(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: PlaqueRouter.getPlaque(id: id)) { (response) in
      completion(response)
    }
  }
  
  public func searchForPlaques(between topLeft: CLLocationCoordinate2D, and bottomRight: CLLocationCoordinate2D, completion: @escaping (APIResponse) -> Void) {
    var topLeftCoord = [topLeft.latitude, topLeft.longitude].description
    var bottomRightCoord = [bottomRight.latitude, bottomRight.longitude].description
    
    topLeftCoord = topLeftCoord.replacingOccurrences(of: " ", with: "")
    bottomRightCoord = bottomRightCoord.replacingOccurrences(of: " ", with: "")
    
    self.request(router: PlaqueRouter.getPlaques(topLeft: topLeftCoord.description, bottomRight: bottomRightCoord.description)) { (response) in
      completion(response)
    }
  }
}

// MARK: - Private helper methods

private extension APIManager {
  
  func request(router: Router, completion: @escaping (APIResponse) -> Void) {
    if let error = containsEmptyElement(details: router.parameters) {
      completion(.failure(error: error))
      return
    }
    
    Alamofire.request(router)
      .validate()
      .responseJSON { (response) in
        switch response.result {
        case .success(let value):
          completion(.success(json: JSON(value)))
        case .failure:
          var error = NSError(domain: "Amble",
                              code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Network error",
                                         NSLocalizedFailureReasonErrorKey: "Please try again later."])
          
          if let res = response.response, let data = response.data {
            let json = JSON(data)
            let description = router.path.replacingOccurrences(of: "/auth/", with: "").capitalized + " error"
            let reason = json["error"].stringValue
            
            error = NSError(domain: "Amble",
                            code: res.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: description,
                                       NSLocalizedFailureReasonErrorKey: reason])
          }
          
          completion(.failure(error: error))
        }
    }
  }
  
  func upload(data: Data, to url: String, headers: HTTPHeaders, completion: @escaping (APIResponse) -> Void) {
    Alamofire.upload(data, to: url, method: .put, headers: headers)
      .validate()
      .responseString { (response) in
        switch response.result {
        case .success:
          completion(.success(json: JSON("{\"success\": true}")))
        case .failure:
          let error = NSError(domain: "Amble",
                              code: (response.response?.statusCode)!,
                              userInfo: [NSLocalizedDescriptionKey: "Upload Error"])
          completion(.failure(error: error))
        }
    }
  }
  
  func createWalk(name: String, members: [String]?, locations: [CLLocation], achievements: [Achievement], image: String, time: Int, distance: Double, steps: Int, completion: @escaping (APIResponse) -> Void) {
    
    var coordinates: [[Double]] = []
    for location in locations {
      coordinates.append([location.coordinate.longitude, location.coordinate.latitude])
    }
    
    var achievementsDict: [[String: Any]] = []
    for achievement in achievements {
      achievementsDict.append(["name": achievement.type.rawValue, "value": achievement.value])
    }
    
    let achievementsJSON = JSON(achievementsDict)
    
    if let achievementsString = achievementsJSON.rawString(.ascii, options: []) {
      var details = ["name": name,
                     "coordinates": coordinates.description,
                     "achievements": achievementsString,
                     "image": image,
                     "time": time,
                     "distance": distance,
                     "steps": steps] as [String : Any]
      
      if let members = members {
        details["members"] = members.description
      }
      
      request(router: AmbleRouter.createWalk(details: details)) { (response) in
        completion(response)
      }
    } else {
      completion(.failure(error: NSError(domain: "Amble", code: 500, userInfo: nil)))
    }
  }
  
  
  func containsEmptyElement(details: [String: Any]) -> NSError? {
    for (key, value) in details {
      if String(describing: value).isEmpty {
        return NSError(domain: "Amble",
                       code: 400,
                       userInfo: [NSLocalizedDescriptionKey: "Please enter your \(key)."])
      }
    }
    
    return nil
  }
}

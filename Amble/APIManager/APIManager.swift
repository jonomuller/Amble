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
  
  // MARK: - Private helper functions
  
  private func request(router: Router, completion: @escaping (APIResponse) -> Void) {
    if let error = containsEmptyElement(details: router.parameters as! [String: String]) {
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
          if let data = response.data {
            let json = JSON(data)
            let description = router.path.replacingOccurrences(of: "/auth/", with: "").capitalized + " error"
            let reason = json["error"].stringValue
            let error = NSError(domain: "Amble",
                                code: (response.response?.statusCode)!,
                                userInfo: [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: reason])
            completion(.failure(error: error))
          }
        }
    }
  }
  
  private func containsEmptyElement(details: [String: String]) -> NSError? {
    for (key, value) in details {
      if value.isEmpty {
        return NSError(domain: "Amble",
                       code: 400,
                       userInfo: [NSLocalizedDescriptionKey: "Please enter your \(key)."])
      }
    }
    
    return nil
  }
  
  // MARK: - /auth API calls
  
  public func login(username: String, password: String, completion: @escaping (APIResponse) -> Void) {
    let details = ["username": username, "password": password]
    request(router: .login(details: details)) { (response) in
      completion(response)
    }
  }
  
  public func register(username: String, email: String, password: String, firstName: String, lastName: String, completion: @escaping (APIResponse) -> Void) {
    let details = ["username": username,
                   "email": email,
                   "password": password,
                   "firstName": firstName,
                   "lastName": lastName]
    
    request(router: .register(details: details)) { (response) in
      completion(response)
    }
  }
  
  // MARK: - /walks API calls
  
  public func createWalk(name: String, owner: String, locations: [CLLocation], time: Int, distance: Double, steps: Double, completion: @escaping (APIResponse) -> Void) {
    var coordinates: [[Double]] = []
    for location in locations {
      coordinates.append([location.coordinate.longitude, location.coordinate.latitude])
    }
    
    let details = ["name": name,
                   "owner": owner,
                   "coordinates": coordinates.description,
                   "time": time,
                   "distance": distance,
                   "steps": steps] as [String : Any]
    
    request(router: .createWalk(details: details)) { (response) in
      completion(response)
    }
  }
  
  public func getWalk(id: String, completion: @escaping (APIResponse) -> Void) {
    request(router: .getWalk(id: id)) { (response) in
      completion(response)
    }
  }
}

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
  
  // MARK: - /auth API calls
  
  public func login(username: String, password: String, completion: @escaping (APIResponse) -> Void) {
    let details = ["username": username, "password": password]
    self.request(router: .login(details: details)) { (response) in
      completion(response)
    }
  }
  
  public func register(username: String, email: String, password: String, firstName: String, lastName: String, completion: @escaping (APIResponse) -> Void) {
    let details = ["username": username,
                   "email": email,
                   "password": password,
                   "firstName": firstName,
                   "lastName": lastName]
    
    self.request(router: .register(details: details)) { (response) in
      completion(response)
    }
  }
  
  // MARK: - /walks API calls
  
  public func createWalk(name: String, owner: String, locations: [CLLocation], image: UIImage, time: Int, distance: Double, steps: Int, completion: @escaping (APIResponse) -> Void) {
    
    self.request(router: .getMapImageURL) { (response) in
      switch response {
      case .success(let json):
        let url = json["url"].stringValue
        if let imageData = UIImageJPEGRepresentation(image, 1) {
          self.upload(data: imageData, to: url, headers: ["Content-Type":"image/jpeg"], completion: { (uploadResponse) in
            switch uploadResponse {
            case .success:
              // Create walk
              let imageURL = url.components(separatedBy: "?")[0]
              self.createWalk(name: name, owner: owner, locations: locations, image: imageURL, time: time, distance: distance, steps: steps, completion: { (createResponse) in
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
    self.request(router: .getWalk(id: id)) { (response) in
      completion(response)
    }
  }
  
  // MARK: - /users API calls
  
  public func getWalks(id: String, completion: @escaping (APIResponse) -> Void) {
    self.request(router: .getWalks(id: id)) { (response) in
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
          if let data = response.data {
            let json = JSON(data)
            let description = router.path.replacingOccurrences(of: "/auth/", with: "").capitalized + " error"
            let reason = json["error"].stringValue
            let error = NSError(domain: "Amble",
                                code: (response.response?.statusCode)!,
                                userInfo: [NSLocalizedDescriptionKey: description,
                                           NSLocalizedFailureReasonErrorKey: reason])
            completion(.failure(error: error))
          }
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
  
  func createWalk(name: String, owner: String, locations: [CLLocation], image: String, time: Int, distance: Double, steps: Int, completion: @escaping (APIResponse) -> Void) {
    var coordinates: [[Double]] = []
    for location in locations {
      coordinates.append([location.coordinate.longitude, location.coordinate.latitude])
    }
    
    let details = ["name": name,
                   "owner": owner,
                   "coordinates": coordinates.description,
                   "image": image,
                   "time": time,
                   "distance": distance,
                   "steps": steps] as [String : Any]
    
    request(router: .createWalk(details: details)) { (response) in
      completion(response)
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

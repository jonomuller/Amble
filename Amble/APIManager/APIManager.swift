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

class APIManager: NSObject {
  
  public static let sharedInstance = APIManager()
  
  /*
   Define response from API as either returning JSON (success) or an error (failure)
   */
  enum APIResponse {
    case success(json: JSON)
    case failure(error: NSError)
  }
  
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
            let message = json["error"].stringValue
            let error = NSError(domain: "Amble",
                                code: (response.response?.statusCode)!,
                                userInfo: [NSLocalizedDescriptionKey: message])
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
  
  // MARK: /auth API calls
  
  public func login(username: String, password: String, completion: @escaping (APIResponse) -> Void) {
    let details = ["username": username,
                   "password": password]
    
    request(router: Router.login(details: details)) { (response) in
      completion(response)
    }
  }
  
  public func register(username: String, email: String, password: String, firstName: String, lastName: String, completion: @escaping (APIResponse) -> Void) {
    let details = ["username": username,
                   "email": email,
                   "password": password,
                   "firstName": firstName,
                   "lastName": lastName]
    
    request(router: Router.register(details: details)) { (response) in
      completion(response)
    }
  }
  
}

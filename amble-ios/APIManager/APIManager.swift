//
//  APIManager.swift
//  amble-ios
//
//  Created by Jono Muller on 03/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class APIManager: NSObject {
  
  public static let sharedInstance = APIManager()
  
  private func request(router: Router, completion: @escaping (JSON, NSError?) -> Void) {
    Alamofire.request(router)
      .validate()
      .responseJSON { response in
        switch response.result {
        case .success(let value):
          completion(JSON(value), nil)
        case .failure:
          if let data = response.data {
            let json = JSON(data)
            let message = json["error"].stringValue
            let error = NSError(domain: "amble-ios",
                                code: (response.response?.statusCode)!,
                                userInfo: [NSLocalizedDescriptionKey: message])
            completion(json, error)
          }
        }
    }
  }
  
  // MARK: /auth API calls
  
  public func login(with details: [String: Any], completion: @escaping (JSON, NSError?) -> Void) {
    request(router: Router.login(details: details)) { (json, error) in
      completion(json, error)
    }
  }
  
}

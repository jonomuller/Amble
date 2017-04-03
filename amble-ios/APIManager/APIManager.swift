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
  
  public func login(with details: [String: Any], completion: @escaping (JSON, NSError?) -> Void) {
    
    Alamofire.request(Router.login(details: details))
      .validate()
      .responseJSON { (response) in
        completion(JSON(response.result.value!), nil)
    }
  }
  
}

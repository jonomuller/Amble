//
//  APIResponse.swift
//  Amble
//
//  Created by Jono Muller on 13/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 Define response from API as either returning JSON (success) or an error (failure)
 */
enum APIResponse {
  case success(json: JSON)
  case failure(error: NSError)
  
  var success: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  var value: Any {
    switch self {
    case .success(let json):
      return json
    case .failure(let error):
      return error
    }
  }
}

//
//  PlaqueRouter.swift
//  Amble
//
//  Created by Jono Muller on 25/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire

enum PlaqueRouter: Router {
  
  static var baseURLPath: String = "http://openplaques.org"
  
  case getPlaque(id: String)
  case getPlaques(topLeft: String, bottomRight: String)
  case getPerson(id: String)
  
  var method: HTTPMethod {
    return .get
  }
  
  var path: String {
    switch self {
    case .getPlaque(let id):
      return "/plaques/\(id).json"
    case .getPlaques(let topLeft, let bottomRight):
      return "/plaques.json?box=\(topLeft),\(bottomRight)"
    case .getPerson(let id):
      return "/people/\(id).json"
    }
  }
  
  var parameters: [String : Any] {
    return [:]
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try (PlaqueRouter.baseURLPath + path).asURL()
    return try URLRequest(url: url, method: method)
  }
}

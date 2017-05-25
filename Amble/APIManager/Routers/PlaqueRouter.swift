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
  
  static var baseURLPath: String = "http://openplaques.org/plaques"
  
  case getPlaque(id: String)
  case getPlaques(topLeft: String, bottomRight: String)
  
  var method: HTTPMethod {
    return .get
  }
  
  var path: String {
    switch self {
    case .getPlaque(let id):
      return "/\(id).json"
    case .getPlaques(let lat, let lon):
      return ".json?box=\(lat),\(lon)"
    }
  }
  
  var parameters: [String : Any] {
    return [:]
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try AmbleRouter.baseURLPath.asURL();
    let urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    return try URLEncoding.default.encode(urlRequest, with: parameters)
  }
}

//
//  Router.swift
//  amble-ios
//
//  Created by Jono Muller on 03/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire

enum Router: URLRequestConvertible {
  
  static let baseURLPath = "http://amble-api.herokuapp.com/api"
  
  case login(details: Parameters)
  case register(details: Parameters)
  
  var method: HTTPMethod {
    return .post
  }
  
  var path: String {
    switch self {
    case .login:
      return "/auth/login"
    case .register:
      return "/auth/register"
    }
  }
  
  var parameters: [String: Any] {
    switch self {
    case .login(let details):
      return details
    case .register(let details):
      return details
    }
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try Router.baseURLPath.asURL();
    let urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    return try URLEncoding.default.encode(urlRequest, with: parameters)
  }
  
}

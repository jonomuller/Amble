//
//  Router.swift
//  Amble
//
//  Created by Jono Muller on 03/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire

enum Router: URLRequestConvertible {
  
  static let baseURLPath = "http://ambleapp.herokuapp.com/api"
  
  // /auth
  case login(details: Parameters)
  case register(details: Parameters)
  
  // /walks
  case createWalk(details: Parameters)
  case getMapImageURL
  case getWalk(id: String)
  
  // /users
  case getWalks(id: String)
  
  var method: HTTPMethod {
    switch self {
    case .login, .register, .createWalk:
      return .post
    case .getWalk, .getWalks, .getMapImageURL:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .login:
      return "/auth/login"
    case .register:
      return "/auth/register"
    case .createWalk:
      return "/walks/create"
    case .getMapImageURL:
      return "/walks/create/upload"
    case .getWalk(let id):
      return "/walks/\(id)"
    case .getWalks(let id):
      return "/users/\(id)/walks"
    }
  }
  
  var parameters: [String: Any] {
    switch self {
    case .login(let details):
      return details
    case .register(let details):
      return details
    case .createWalk(let details):
      return details
    default:
      return [:]
    }
  }
  
  var requiresJWTAuth: Bool {
    switch self {
    case .createWalk, .getWalk, .getWalks, .getMapImageURL:
      return true
    default:
      return false
    }
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try Router.baseURLPath.asURL();
    var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    if requiresJWTAuth {
      urlRequest.setValue("JWT \(User.sharedInstance.userInfo!.jwt)", forHTTPHeaderField: "Authorization")
    }
    
    return try URLEncoding.default.encode(urlRequest, with: parameters)
  }
  
}

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
  
  case login(details: Parameters)
  case register(details: Parameters)
  case createWalk(details: Parameters)
  case getWalk(id: String)
  
  var method: HTTPMethod {
    switch self {
    case .login, .register, .createWalk:
      return .post
    case .getWalk:
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
    case .getWalk(let id):
      return "/walks/\(id)"
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
  
  func asURLRequest() throws -> URLRequest {
    let url = try Router.baseURLPath.asURL();
    let urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    return try URLEncoding.default.encode(urlRequest, with: parameters)
  }
  
}

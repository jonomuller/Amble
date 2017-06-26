//
//  AmbleRouter.swift
//  Amble
//
//  Created by Jono Muller on 03/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire

enum AmbleRouter: Router {
  
  static var baseURLPath: String = "http://ambleapp.herokuapp.com/api"
  
  // /auth
  case login(details: Parameters)
  case register(details: Parameters)
  
  // /walks
  case createWalk(details: Parameters)
  case getMapImageURL
  case getWalk(id: String)
  case deleteWalk(id: String)
  
  // /users
  case getInfo(id: String)
  case getWalks(id: String)
  case userSearch(info: String)
  case registerToken(token: String)
  case invite(details: Parameters)
  case getSentInvites
  case getReceivedInvites
  
  // /invites
  case acceptInvite(id: String)
  case declineInvite(id: String)
  case startWalk(id: String)
  
  var method: HTTPMethod {
    switch self {
    case .login, .register, .createWalk, .invite:
      return .post
    case .getWalk, .getWalks, .getMapImageURL, .getInfo, .userSearch, .registerToken,
         .getSentInvites, .getReceivedInvites, .acceptInvite, .declineInvite, .startWalk:
      return .get
    case .deleteWalk:
      return .delete
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
    case .deleteWalk(let id):
      return "/walks/\(id)"
    case .getInfo(let id):
      return "/users/\(id)"
    case .getWalks(let id):
      return "/users/\(id)/walks"
    case .userSearch(let info):
      return "/users/search/\(info)"
    case .registerToken(let token):
      return "/users/register/\(token)"
    case .invite:
      return "/users/invite"
    case .getSentInvites:
      return "/users/invites/sent"
    case .getReceivedInvites:
      return "/users/invites/received"
    case .acceptInvite(let id):
      return "/invites/\(id)/accept"
    case .declineInvite(let id):
      return "/invites/\(id)/decline"
    case .startWalk(let id):
      return "/invites/\(id)/start_walk"
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
    case .invite(let details):
      return details
    default:
      return [:]
    }
  }
  
  var requiresJWTAuth: Bool {
    switch self {
    case .login, .register, .userSearch:
      return false
    default:
      return true
    }
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try AmbleRouter.baseURLPath.asURL();
    var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    if requiresJWTAuth {
      urlRequest.setValue("JWT \(User.sharedInstance.userInfo!.jwt)", forHTTPHeaderField: "Authorization")
    }
    
    return try URLEncoding.default.encode(urlRequest, with: parameters)
  }
  
}

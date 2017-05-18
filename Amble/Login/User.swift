//
//  User.swift
//  Amble
//
//  Created by Jono Muller on 10/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation
import Locksmith

struct UserInfo: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
  
  let user: OtherUser
  let jwt: String
  
  let service: String = Bundle.main.infoDictionary![String(kCFBundleIdentifierKey)] as? String ?? "Amble"
  
  var account: String {
    return "Amble"
  }
  
  var data: [String : Any] {
    return ["id": user.id,
            "username": user.username,
            "email": user.email,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "jwt": jwt]
  }
}

class User {
  static let sharedInstance = User()
  var userInfo: UserInfo?
}

struct OtherUser {
  
  let id: String
  let username: String
  let email: String
  let firstName: String
  let lastName: String
  
}

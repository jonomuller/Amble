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
  
  let id: String
  let username: String
  let email: String
  let firstName: String
  let lastName: String
  let jwt: String
  
  let service: String = Bundle.main.infoDictionary![String(kCFBundleIdentifierKey)] as? String ?? "Amble"
  
  var account: String {
    return "Amble"
  }
  
  var data: [String : Any] {
    return ["id": id,
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "jwt": jwt]
  }
}

class User {
  static let sharedInstance = User()
  var userInfo: UserInfo?
}

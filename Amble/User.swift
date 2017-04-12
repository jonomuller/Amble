//
//  User.swift
//  Amble
//
//  Created by Jono Muller on 10/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation
import Locksmith

struct User: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
  
  let username: String
  let jwt: String
  
  let service: String = "Amble"
  
  var account: String {
    return service
  }
  
  var data: [String : Any] {
    return ["username": username,
            "jwt": jwt]
  }
}

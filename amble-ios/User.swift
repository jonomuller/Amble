//
//  User.swift
//  amble-ios
//
//  Created by Jono Muller on 10/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation
import Locksmith

struct User: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
  
  let username: String
  let jwt: String
  
  var service: String = "Amble"
  
  var account: String {
    return username
  }
  
  var data: [String : Any] {
    return ["jwt": jwt]
  }
}

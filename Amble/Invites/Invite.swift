//
//  Invite.swift
//  Amble
//
//  Created by Jono Muller on 13/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

struct Invite {
  
  let id: String
  let users: [OtherUser]
  let date: Date
  var accepted: Bool
  
}

enum InviteType {
  
  case sent
  case received
  
  var option: String {
    switch self {
    case .sent:
      return "to"
    case .received:
      return "from"
    }
  }
  
}

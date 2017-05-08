//
//  Achievement.swift
//  Amble
//
//  Created by Jono Muller on 09/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation

enum Achievement {
  
  case distance
  case dayStreak(day: Int)
  case group
  
  var rawValue: String {
    switch self {
    case .distance:
      return "DISTANCE"
    case .dayStreak:
      return "DAY_STREAK"
    case .group:
      return "GROUP"
    }
  }
  
  var description: String {
    switch self {
    case .distance:
      return "Distance walked"
    case .dayStreak(let day):
      return "\(day) day streak"
    case .group:
      return "Walk with other people"
    }
  }
}

//
//  Achievement.swift
//  Amble
//
//  Created by Jono Muller on 09/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Foundation

enum AchievementType: String {
  
  case distance = "DISTANCE"
  case dayStreak = "DAY_STREAK"
  case group = "GROUP"
}

struct Achievement {
  let type: AchievementType
  let value: Int
  
  var description: String {
    switch type {
    case .distance:
      return "Distance walked"
    case .dayStreak:
      let day = value / 100
      return "\(day) day streak"
    case .group:
      return "Walk with other people"
    }
  }
}

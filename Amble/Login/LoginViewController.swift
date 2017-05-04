//
//  LoginViewController.swift
//  Amble
//
//  Created by Jono Muller on 08/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class LoginViewController: EntryViewController {
  
  override var sections: [String] {
    return ["username", "password"]
  }
  
  override func entryButtonPressed(details: [String: String]) {
    APIManager.sharedInstance.login(username: details[sections[0]]!.lowercased(), password: details[sections[1]]!) { (response) in
      self.handleAPIResponse(response: response)
    }
  }
}

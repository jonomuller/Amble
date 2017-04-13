//
//  RegisterViewController.swift
//  Amble
//
//  Created by Jono Muller on 13/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class RegisterViewController: EntryViewController {
  
  override var sections: [String] {
    return ["username", "email address", "password", "first name", "last name"]
  }
  
  override func entryButtonPressed() {
    // register here
  }
  
  override func textFieldsAreValid() -> Bool {
    // check for no empty cells and valid email
    return false
  }
}

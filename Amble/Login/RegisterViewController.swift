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
  
  override func entryButtonPressed(details: [String: String]) {
    APIManager.sharedInstance.register(username: details[sections[0]]!.lowercased(),
                                       email: details[sections[1]]!.lowercased(),
                                       password: details[sections[2]]!,
                                       firstName: details[sections[3]]!.capitalized,
                                       lastName: details[sections[4]]!.capitalized) { (response) in
      self.handleAPIResponse(response: response)
    }
  }
  
  override func isValidTextField(textField: UITextField) -> Bool {
    if textField.placeholder == sections[1] {
      return isValidEmail(email: textField.text!)
    }
    
    return !(textField.text?.isEmpty)!
  }
  
  func isValidEmail(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
  }
}

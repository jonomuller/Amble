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
    let deviceToken = UserDefaults.standard.object(forKey: AppDelegate.DEVICE_TOKEN_KEY) as? String
    APIManager.sharedInstance.register(username: details[sections[0]]!.lowercased(),
                                       email: details[sections[1]]!.lowercased(),
                                       password: details[sections[2]]!,
                                       firstName: details[sections[3]]!.capitalized,
                                       lastName: details[sections[4]]!.capitalized,
                                       deviceToken: deviceToken) { (response) in
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath) as! EntryTableViewCell
    let section = sections[indexPath.row]
    
    if section == sections[1] {
      cell.setTextFieldImageFromText(text: "@", size: 25)
    } else if section == sections[3] || section == sections[4] {
      cell.setTextFieldImageFromText(text: "Aa", size: 18)
    }
    
    return cell
  }
}

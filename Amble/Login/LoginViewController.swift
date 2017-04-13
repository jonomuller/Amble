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
  
  override func entryButtonPressed() {
    let details = getDataFromCells()
    
    APIManager.sharedInstance.login(username: details[sections[0]]!, password: details[sections[1]]!) { (json, error) in
      self.entryButton.expand(completion: nil)
      
      if (error != nil) {
        let alertView = UIAlertController(title: "Log in error", message: error?.localizedDescription, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
      } else {
        let user = User(username: (json?["user"].stringValue)!, jwt: (json?["jwt"].stringValue)!)
        
        // Save user data to keychain
        do {
          try user.createInSecureStore()
          print("Login successful")
        } catch {
          print("Error saving to keychain: \(error)")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController")
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
      }
    }
  }
  
  override func textFieldsAreValid() -> Bool {
    var noEmptyCells = true
    
    // Check if any of the text fields are empty
    if let indexPaths = tableView.indexPathsForVisibleRows {
      for indexPath in indexPaths {
        let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
        if (cell.textField.text?.isEmpty)! {
          noEmptyCells = false
        }
      }
    }
    
    return noEmptyCells
  }
}

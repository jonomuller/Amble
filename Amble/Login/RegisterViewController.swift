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
    let details = getDataFromCells()
    
    APIManager.sharedInstance.register(username: details[sections[0]]!, email: details[sections[1]]!, password: details[sections[2]]!, firstName: details[sections[3]]!, lastName: details[sections[4]]!) { (response) in
      self.entryButton.expand(completion: nil)
      
      switch response {
      case .success(let json):
        let user = User(username: (json["user"].stringValue), jwt: json["jwt"].stringValue)
        
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
      case .failure(let error):
        let alertView = UIAlertController(title: "Log in error", message: error.localizedDescription, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
      }
    }
  }
  
  override func textFieldsAreValid() -> Bool {
    // check for no empty cells and valid email
    return false
  }
}

//
//  SettingsTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 16/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import ChameleonFramework
import Locksmith

class SettingsTableViewController: UITableViewController {
  
  fileprivate let SETTINGS_CELL_IDENTIFIER = "settingsCell"
  fileprivate let sections = [["Log Out"]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Settings"
    self.setStatusBarStyle(UIStatusBarStyleContrast)
  }
}

// MARK: - Table view data source

extension SettingsTableViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_CELL_IDENTIFIER, for: indexPath)
    
    cell.textLabel?.text = sections[indexPath.section][indexPath.row]
    
    if indexPath.section == sections.count - 1 {
      cell.textLabel?.textColor = .red
    }
    
    return cell
  }
}

// MARK: - Table view delegate

extension SettingsTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == sections.count - 1 {
      displayLogoutAlert()
    }
  }
}

// MARK: - Private helper methods

private extension SettingsTableViewController {
  
  func displayLogoutAlert() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
      self.logout()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
      if let indexPath = self.tableView.indexPathForSelectedRow {
        self.tableView.deselectRow(at: indexPath, animated: false)
      }
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func logout() {
    // Delete user's details from keychain
    do {
      try User.sharedInstance.userInfo?.deleteFromSecureStore()
      User.sharedInstance.userInfo = nil
    } catch {
      print("Error deleting in keychain: \(error)")
    }
    
    // Return to initial view controller
    self.setRootView(to: "Login")
  }
}

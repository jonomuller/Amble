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
  fileprivate let PREFFERED_DISTANCE_UNIT = "PreferredDistanceUnit"
  fileprivate let sections = [["mi", "km"],["Log Out"]]
  
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
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    var title: String?
    
    if section == 0 {
      title = "Preferred distance unit"
    }
    
    return title
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_CELL_IDENTIFIER, for: indexPath)
    
    let value = sections[indexPath.section][indexPath.row]
    cell.textLabel?.text = value
    
    if indexPath.section == 0 {
      if let unit = UserDefaults.standard.value(forKey: PREFFERED_DISTANCE_UNIT) as? String {
        if unit == value {
          cell.accessoryType = .checkmark
        } else {
          cell.accessoryType = .none
        }
      } else {
        UserDefaults.standard.set("km", forKey: PREFFERED_DISTANCE_UNIT)
        if value == "km" {
          cell.accessoryType = .checkmark
        }
      }
    } else if indexPath.section == sections.count - 1 {
      cell.textLabel?.textColor = .red
    }
    
    return cell
  }
}

// MARK: - Table view delegate

extension SettingsTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 0 {
      UserDefaults.standard.set(sections[indexPath.section][indexPath.row], forKey: PREFFERED_DISTANCE_UNIT)
      self.tableView.reloadData()
    } else if indexPath.section == sections.count - 1 {
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

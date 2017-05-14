//
//  InviteUserTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 14/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import SwiftyJSON

class InviteUserTableViewController: UITableViewController {
  
  @IBOutlet var searchBar: UISearchBar!
  
  fileprivate let USER_CELL_IDENTIFIER = "UserCell"
  
  fileprivate var users: [OtherUser] = []
  fileprivate var selectedUser: OtherUser?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite",
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(inviteButtonPressed))
  }
}

// MARK: - Table view data source

extension InviteUserTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: USER_CELL_IDENTIFIER, for: indexPath)
    let user = users[indexPath.row]
    
    cell.textLabel?.text = user.firstName + " " + user.lastName
    cell.detailTextLabel?.text = user.username
    
    return cell
  }
}

// MARK: - Table view delegate

extension InviteUserTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.navigationItem.rightBarButtonItem?.isEnabled = true
    self.selectedUser = users[indexPath.row]
    
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
  }
  
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    self.selectedUser = nil
    
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .none
  }
}

// MARK: - Search bar delegate

extension InviteUserTableViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.users = []
    if let userInfo = searchBar.text {
      APIManager.sharedInstance.userSearch(info: userInfo, completion: { (response) in
        switch response {
        case .success(let json):
          for (_, subJson): (String, JSON) in json["users"] {
            let user = OtherUser(id: subJson["id"].stringValue,
                                 username: subJson["username"].stringValue,
                                 email: subJson["email"].stringValue,
                                 firstName: subJson["name"]["firstName"].stringValue,
                                 lastName: subJson["name"]["lastName"].stringValue)
            self.users.append(user)
          }
          self.tableView.reloadData()
          self.searchDisplayController?.isActive = false
        case .failure(let error):
          self.displayErrorAlert(error: error)
        }
      })
    }
  }
}

// MARK: - Action methods

extension InviteUserTableViewController {
  func inviteButtonPressed() {
    if let id = selectedUser?.id {
      APIManager.sharedInstance.invite(id: id, date: Date(), completion: { (response) in
        switch response {
        case .success(let json):
          print(json)
          self.navigationController?.popViewController(animated: true)
        case .failure(let error):
          self.displayErrorAlert(error: error)
        }
      })
    }
  }
}

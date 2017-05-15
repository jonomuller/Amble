//
//  InviteUserTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 14/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class InviteUserTableViewController: UITableViewController {
  
  @IBOutlet var searchBar: UISearchBar!
  
  fileprivate let USER_CELL_IDENTIFIER = "UserCell"
  
  fileprivate var users: [OtherUser] = []
  fileprivate var selectedUsers: [OtherUser] = []
  fileprivate var noResults: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = self.createInviteButton()
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    self.navigationController?.hidesNavigationBarHairline = true
    
    searchBar.becomeFirstResponder()
    searchBar.backgroundImage = UIImage()
  }
}

// MARK: - Table view data source

extension InviteUserTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if noResults {
      return 1
    }
    
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: USER_CELL_IDENTIFIER, for: indexPath)
    
    cell.accessoryType = .none
    
    if noResults {
      cell.textLabel?.text = "No results found."
      cell.detailTextLabel?.text = nil
    } else {
      let user = users[indexPath.row]
      cell.textLabel?.text = user.firstName + " " + user.lastName
      cell.detailTextLabel?.text = user.username
      
      if selectedUsers.contains(where: { $0.id == user.id }) {
        cell.accessoryType = .checkmark
      }
    }
    
    return cell
  }
}

// MARK: - Table view delegate

extension InviteUserTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    
    if cell?.accessoryType == UITableViewCellAccessoryType.none {
      if selectedUsers.count == 0 {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
      }
      
      selectedUsers.append(users[indexPath.row])
      cell?.accessoryType = UITableViewCellAccessoryType.checkmark
    } else if cell?.accessoryType == .checkmark {
      if selectedUsers.count == 1 {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
      }
      
      selectedUsers = selectedUsers.filter({ $0.id != users[indexPath.row].id })
      cell?.accessoryType = .none
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Search bar delegate

extension InviteUserTableViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    users = []
    if let userInfo = searchBar.text {
      let spinner = self.view.createIndicatorView(width: 50, height: 50)
      spinner.startAnimating()
      
      APIManager.sharedInstance.userSearch(info: userInfo, completion: { (response) in
        spinner.stopAnimating()
        
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
          
          if self.users.count == 0 {
            self.noResults = true
          } else {
            self.noResults = false
          }
          
          self.tableView.reloadData()
          searchBar.resignFirstResponder()
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
    if selectedUsers.count == 0 {
      return
    }
    
    let spinner = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20),
                                          type: .ballScaleRippleMultiple,
                                          color: .white,
                                          padding: nil)
    spinner.startAnimating()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    let ids = selectedUsers.map({ return $0.id })
    
    APIManager.sharedInstance.invite(ids: ids, date: Date(), completion: { (response) in
      spinner.stopAnimating()
      self.navigationItem.rightBarButtonItem = self.createInviteButton()
      
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

// MARK: - Private helper methods

private extension InviteUserTableViewController {
  func createInviteButton() -> UIBarButtonItem {
    return UIBarButtonItem(title: "Invite",
                           style: .done,
                           target: self,
                           action: #selector(self.inviteButtonPressed))
  }
}

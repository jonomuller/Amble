//
//  InviteUserViewController.swift
//  Amble
//
//  Created by Jono Muller on 14/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class InviteUserViewController: UIViewController {
  
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  
  fileprivate let USER_CELL_IDENTIFIER = "UserCell"
  
  fileprivate var users: [OtherUser] = []
  fileprivate var selectedUsers: [OtherUser] = []
  fileprivate var noResults: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = self.inviteBarButtonItem
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    self.navigationController?.hidesNavigationBarHairline = true
    
    searchBar.becomeFirstResponder()
    searchBar.backgroundImage = UIImage()
  }
}

// MARK: - Table view data source

extension InviteUserViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if selectedUsers.count > 0 {
      return 2
    }
    
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedUsers.count > 0 && section == 1 {
      return selectedUsers.count
    }
    
    if noResults {
      return 1
    }
    
    return users.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if users.count > 0 || noResults {
      if section == 0 {
        return "Search Results"
      } else if section == 1 {
        return "Selected Users"
      }
    }
    
    return nil
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: USER_CELL_IDENTIFIER, for: indexPath)
    
    cell.isUserInteractionEnabled = true
    cell.accessoryType = .none
    
    if tableView.numberOfSections > 1 && indexPath.section == 1 {
      let selectedUser = selectedUsers[indexPath.row]
      cell.textLabel?.text = selectedUser.firstName + " " + selectedUser.lastName
      cell.detailTextLabel?.text = selectedUser.username
      cell.accessoryType = .checkmark
    } else if noResults {
      cell.isUserInteractionEnabled = false
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

extension InviteUserViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    
    if tableView.numberOfSections > 1 && indexPath.section == 1 {
      
      self.tableView.beginUpdates()
      self.tableView.deleteRows(at: [indexPath], with: .fade)
      
      if selectedUsers.count == 1 {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.deleteSections([indexPath.section], with: .fade)
      }
      
      self.tableView.reloadSections([indexPath.section - 1], with: .fade)
      
      selectedUsers = selectedUsers.filter({ $0.id != selectedUsers[indexPath.row].id })
      self.tableView.endUpdates()
      cell?.accessoryType = .none
      
    } else if cell?.accessoryType == UITableViewCellAccessoryType.none {
      
      self.tableView.beginUpdates()
      if selectedUsers.count == 0 {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.tableView.insertSections([indexPath.section + 1], with: .fade)
        self.tableView.reloadSections([indexPath.section], with: .fade)
      }
      
      self.tableView.insertRows(at: [IndexPath(row: selectedUsers.count, section: indexPath.section + 1)],
                                with: .fade)
      
      selectedUsers.append(users[indexPath.row])
      self.tableView.endUpdates()
      cell?.accessoryType = .checkmark
      
    } else if cell?.accessoryType == .checkmark {

      self.tableView.beginUpdates()
      self.tableView.deleteRows(at: [IndexPath(row: selectedUsers.index(where: { $0.id == users[indexPath.row].id })!,
                                               section: indexPath.section + 1)],
                                with: .fade)
      
      if selectedUsers.count == 1 {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.deleteSections([indexPath.section + 1], with: .fade)
        self.tableView.reloadSections([indexPath.section], with: .fade)
      }
      
      selectedUsers = selectedUsers.filter({ $0.id != users[indexPath.row].id })
      self.tableView.endUpdates()
      cell?.accessoryType = .none
      
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Search bar delegate

extension InviteUserViewController: UISearchBarDelegate {
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

extension InviteUserViewController {
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
      self.navigationItem.rightBarButtonItem = self.inviteBarButtonItem
      
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

private extension InviteUserViewController {
  var inviteBarButtonItem: UIBarButtonItem {
    return UIBarButtonItem(title: "Invite",
                           style: .done,
                           target: self,
                           action: #selector(self.inviteButtonPressed))
  }
}

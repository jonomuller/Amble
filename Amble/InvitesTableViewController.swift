//
//  InvitesTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 13/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class InvitesTableViewController: UITableViewController {
  
  @IBOutlet var segmentedControl: UISegmentedControl!
  
  fileprivate let INVITE_CELL_IDENTIFIER = "InviteCell"
  
  fileprivate var spinner: NVActivityIndicatorView!
  fileprivate var invites: [Invite] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    spinner = self.tableView.createIndicatorView(width: 50, height: 50)
    spinner.startAnimating()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.getInvites { (invites) in
      if self.invites.count != invites.count {
        self.invites = invites
        DispatchQueue.main.async(execute: { 
          self.tableView.reloadData()
        })
      }
    }
  }
}

// MARK: - Table view data source

extension InvitesTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return invites.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: INVITE_CELL_IDENTIFIER, for: indexPath)
    let invite = invites[indexPath.row]
    
    cell.textLabel?.text = invite.firstName + " " + invite.lastName
    
    return cell
  }
}

// MARK: - Private helper methods

private extension InvitesTableViewController {
  func getInvites(completion: @escaping ([Invite]) -> Void) {
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      APIManager.sharedInstance.getSentInvites(completion: { (response) in
        self.handleAPIResponse(response: response, completion: { (invites) in
          completion(invites)
        })
      })
    case 1:
      APIManager.sharedInstance.getReceivedInvites(completion: { (response) in
        self.handleAPIResponse(response: response, completion: { (invites) in
          completion(invites)
        })
      })
    default:
      break
    }
  }
  
  func handleAPIResponse(response: APIResponse, completion: @escaping ([Invite]) -> Void) {
    self.spinner.stopAnimating()
    switch response {
    case .success(let json):
      var invites: [Invite] = []
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      
      for (_, subJson): (String, JSON) in json["invites"] {
        let invite = Invite(username: subJson["username"].stringValue,
                            firstName: subJson["firstName"].stringValue,
                            lastName: subJson["lastName"].stringValue,
                            date: dateFormatter.date(from: subJson["date"].stringValue)!)
        invites.append(invite)
      }
      
      completion(invites)
    case .failure(let error):
      self.displayErrorAlert(error: error)
    }
  }
}

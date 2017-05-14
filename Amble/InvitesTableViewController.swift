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
  fileprivate var sentInvites: [Invite] = []
  fileprivate var receivedInvites: [Invite] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    spinner = self.tableView.createIndicatorView(width: 50, height: 50)
    spinner.startAnimating()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.getInvites()
  }
}

// MARK: - Table view data source

extension InvitesTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      return sentInvites.count
    case 1:
      return receivedInvites.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: INVITE_CELL_IDENTIFIER, for: indexPath)
    
    var invites: [Invite] = []
    
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      invites = sentInvites
    case 1:
      invites = receivedInvites
    default:
      break
    }
    
    let invite = invites[indexPath.row]
    
    cell.textLabel?.text = invite.firstName + " " + invite.lastName
    
    return cell
  }
}

// MARK: - IBAction methods

extension InvitesTableViewController {
  @IBAction func segmentedControlValueChanged(_ sender: Any) {
    self.tableView.reloadData()
  }
}

// MARK: - Private helper methods

private extension InvitesTableViewController {
  
  func getInvites() {
    APIManager.sharedInstance.getSentInvites(completion: { (response) in
      self.sentInvites = self.handleAPIResponse(response: response)
    })
    
    APIManager.sharedInstance.getReceivedInvites(completion: { (response) in
      self.receivedInvites = self.handleAPIResponse(response: response)
    })
  }
  
  func handleAPIResponse(response: APIResponse) -> [Invite] {
    var invites: [Invite] = []
    self.spinner.stopAnimating()
    
    switch response {
    case .success(let json):
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      
      for (_, subJson): (String, JSON) in json["invites"] {
        let invite = Invite(username: subJson["username"].stringValue,
                            firstName: subJson["firstName"].stringValue,
                            lastName: subJson["lastName"].stringValue,
                            date: dateFormatter.date(from: subJson["date"].stringValue)!)
        invites.append(invite)
      }
      
    case .failure(let error):
      self.displayErrorAlert(error: error)
    }
    
    return invites
  }
}

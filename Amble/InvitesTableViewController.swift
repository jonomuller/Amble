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
  
  fileprivate let SENT_INVITE_CELL_IDENTIFIER = "SentInviteCell"
  fileprivate let RECEIVED_INVITE_CELL_IDENTIFIER = "ReceivedInviteCell"
  
  fileprivate var spinner: NVActivityIndicatorView!
  fileprivate var sentInvites: [Invite] = []
  fileprivate var receivedInvites: [Invite] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setCustomBackButton(image: UIImage(named: "back-button"))
    
    spinner = self.view.createIndicatorView(width: 50, height: 50)
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
    var invites: [Invite] = []
    
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: SENT_INVITE_CELL_IDENTIFIER,
                                           for: indexPath) as! SentInviteTableViewCell
      let invite = sentInvites[indexPath.row]
      cell.nameLabel.text = invite.user.firstName + " " + invite.user.lastName
      cell.dateLabel.text = String(describing: invite.date)
      if invite.accepted {
        cell.acceptedLabel.text = "Accepted"
      } else {
        cell.acceptedLabel.text = "Pending"
      }
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: RECEIVED_INVITE_CELL_IDENTIFIER, for: indexPath)
      invites = receivedInvites
    default:
      break
    }
    
//    let invite = invites[indexPath.row]
    
//    cell.textLabel?.text = invite.user.firstName + " " + invite.user.lastName
//    cell.detailTextLabel?.text = invite.user.username
    
    return tableView.dequeueReusableCell(withIdentifier: SENT_INVITE_CELL_IDENTIFIER,
                                         for: indexPath)
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
      self.sentInvites = self.handleAPIResponse(response: response, option: "to")
    })
    
    APIManager.sharedInstance.getReceivedInvites(completion: { (response) in
      self.receivedInvites = self.handleAPIResponse(response: response, option: "from")
    })
  }
  
  func handleAPIResponse(response: APIResponse, option: String) -> [Invite] {
    self.spinner.stopAnimating()
    var invites: [Invite] = []
    
    switch response {
    case .success(let json):
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      print(json)
      for (_, subJson): (String, JSON) in json["invites"] {
        let user = OtherUser(id: subJson[option]["_id"].stringValue,
                             username: subJson[option]["username"].stringValue,
                             email: subJson[option]["email"].stringValue,
                             firstName: subJson[option]["name"]["firstName"].stringValue,
                             lastName: subJson[option]["name"]["lastName"].stringValue)
        
        let invite = Invite(user: user,
                            date: dateFormatter.date(from: subJson["date"].stringValue)!,
                            accepted: subJson["accepted"].boolValue)
        
        invites.append(invite)
      }
      self.tableView.reloadData()
    case .failure(let error):
      self.displayErrorAlert(error: error)
    }
    
    return invites
  }
}

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
    if segmentedControl.selectedSegmentIndex == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: SENT_INVITE_CELL_IDENTIFIER,
                                           for: indexPath) as! SentInviteTableViewCell
      let invite = sentInvites[indexPath.row]
      cell.nameLabel.text = invite.users.map({ return "\($0.firstName) \($0.lastName)" }).joined(separator: ", ")
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "d/M/yy"
      
      cell.dateLabel.text = dateFormatter.string(from: invite.date)
      
      if invite.accepted {
        cell.acceptedLabel.text = "Accepted"
        cell.startWalkButton.isHidden = false
      } else {
        cell.acceptedLabel.text = "Pending"
        cell.startWalkButton.isHidden = true
      }
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: RECEIVED_INVITE_CELL_IDENTIFIER,
                                               for: indexPath) as! ReceivedInviteTableViewCell
      let invite = receivedInvites[indexPath.row]
      
      cell.fromLabel.text = invite.users[0].firstName + " " + invite.users[0].lastName
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "d/M/yy"
      
      cell.dateLabel.text = dateFormatter.string(from: invite.date)
      
      return cell
    }
  }
}

// MARK: - IBAction methods

extension InvitesTableViewController {
  @IBAction func segmentedControlValueChanged(_ sender: Any) {
    self.tableView.reloadData()
  }
  
  @IBAction func startWalkButtonPressed(_ sender: Any) {
    
  }
  
  @IBAction func acceptButtonPressed(_ sender: Any) {
    if let button = sender as? UIButton, let cell = button.superview?.superview as? ReceivedInviteTableViewCell {
      cell.isUserInteractionEnabled = false
      if let indexPath = tableView.indexPath(for: cell) {
        let id = receivedInvites[indexPath.row].id
        APIManager.sharedInstance.acceptInvite(id: id, completion: { (response) in
          cell.isUserInteractionEnabled = true
          switch response {
          case .success:
            print("Accept invite success")
          case .failure(let error):
            self.displayErrorAlert(error: error)
          }
        })
      }
    }
  }
  
  @IBAction func declineButtonPressed(_ sender: Any) {
    if let button = sender as? UIButton, let cell = button.superview?.superview as? ReceivedInviteTableViewCell {
      cell.isUserInteractionEnabled = false
      if let indexPath = tableView.indexPath(for: cell) {
        let id = receivedInvites[indexPath.row].id
        APIManager.sharedInstance.declineInvite(id: id, completion: { (response) in
          cell.isUserInteractionEnabled = true
          switch response {
          case .success:
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.receivedInvites = self.receivedInvites.filter({ $0.id != id })
            self.tableView.endUpdates()
          case .failure(let error):
            self.displayErrorAlert(error: error)
          }
        })
      }
    }
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
        var users: [OtherUser] = []
        
        if option == "to" {
          for (_, subsubJson): (String, JSON) in subJson["to"] {
            let user = OtherUser(id: subsubJson["_id"].stringValue,
                                   username: subsubJson["username"].stringValue,
                                   email: subsubJson["email"].stringValue,
                                   firstName: subsubJson["name"]["firstName"].stringValue,
                                   lastName: subsubJson["name"]["lastName"].stringValue)
            users.append(user)
          }
        } else {
          users.append(OtherUser(id: subJson[option]["_id"].stringValue,
                               username: subJson[option]["username"].stringValue,
                               email: subJson[option]["email"].stringValue,
                               firstName: subJson[option]["name"]["firstName"].stringValue,
                               lastName: subJson[option]["name"]["lastName"].stringValue))
        }
        
        
        let invite = Invite(id: subJson["_id"].stringValue,
                            users: users,
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

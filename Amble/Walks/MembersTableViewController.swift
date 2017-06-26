//
//  MembersTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 26/06/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class MembersTableViewController: UITableViewController {
  
  var members: [OtherUser]!
  
  fileprivate let MEMBER_CELL_IDENTIFIER = "MemberCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Walk Members"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
  }
  
}

// MARK: - Table view data source

extension MembersTableViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return members.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MEMBER_CELL_IDENTIFIER, for: indexPath)
    
    let member = members[indexPath.row]
    cell.textLabel?.text = member.firstName + " " + member.lastName
    cell.detailTextLabel?.text = member.username
    
    return cell
  }
}

// MARK: - Action methods

extension MembersTableViewController {
  func doneButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
}

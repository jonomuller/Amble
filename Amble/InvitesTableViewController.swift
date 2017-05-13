//
//  InvitesTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 13/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class InvitesTableViewController: UITableViewController {
  
  @IBOutlet var segmentedControl: UISegmentedControl!
  
  fileprivate let INVITE_CELL_IDENTIFIER = "InviteCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// MARK: - Table view data source

extension InvitesTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: INVITE_CELL_IDENTIFIER, for: indexPath)
    
    return cell
  }
}

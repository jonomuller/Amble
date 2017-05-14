//
//  InviteUserTableViewController.swift
//  Amble
//
//  Created by Jono Muller on 14/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class InviteUserTableViewController: UITableViewController {
  
  @IBOutlet var searchBar: UISearchBar!
  
  fileprivate let USER_CELL_IDENTIFIER = "UserCell"
  
  fileprivate var userSearchResults: [OtherUser] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// MARK: - Table view data source

extension InviteUserTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: USER_CELL_IDENTIFIER, for: indexPath)
    
    return cell
  }
}

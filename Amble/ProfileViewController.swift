//
//  ProfileViewController.swift
//  Amble
//
//  Created by Jono Muller on 20/02/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController {
  
  @IBOutlet var collectionView: UICollectionView!
  
  fileprivate var walks: [WalkInfo] = []
  fileprivate let WALK_CELL_IDENTIFIER = "WalkCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.getWalks()
  }
}

// MARK: - Collection view data source

extension ProfileViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WALK_CELL_IDENTIFIER, for: indexPath) as! WalkCollectionViewCell
    cell.nameLabel.text = "Test"
    return cell
  }
}

// MARK: - Private helper methods

private extension ProfileViewController {
  func getWalks() {
    APIManager.sharedInstance.getWalks(id: (User.sharedInstance.userInfo?.id)!) { (response) in
      switch response {
      case .success(let json):
        for (_, subJson): (String, JSON) in json["walks"] {
          let walk = WalkInfo(id: subJson["id"].stringValue,
                              name: subJson["name"].stringValue,
                              image: subJson["image"].stringValue,
                              date: subJson["createdAt"].stringValue)
          self.walks.append(walk)
        }
        
        self.collectionView.reloadData()
      case .failure(let error):
        let alertView = UIAlertController(title: error.localizedDescription,
                                          message: error.localizedFailureReason,
                                          preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
      }
    }
  }
}

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
  fileprivate let CELLS_PER_ROW: CGFloat = 2
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.getWalks()
  }
}

// MARK: - Collection view data source

extension ProfileViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return walks.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WALK_CELL_IDENTIFIER, for: indexPath) as! WalkCollectionViewCell
    
    let walk = walks[indexPath.row]
    
    cell.nameLabel.text = walk.name
    cell.dateLabel.text = walk.date
    cell.imageView.layer.cornerRadius = 8
    cell.imageView.clipsToBounds = true
    do {
      if let url = URL(string: walk.image) {
        try cell.imageView.image = UIImage(data: Data(contentsOf: url))
      }
    } catch {
      print("Error fetching photo")
    }
    
    return cell
  }
}

// MARK: - Collection view flow layout delegate

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = (view.frame.width - 20.0 * (CELLS_PER_ROW + 1)) / CELLS_PER_ROW
    let size = CGSize(width: cellWidth, height: cellWidth + 50)
    return size
  }
}

// MARK: - Navigation

extension ProfileViewController {
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? WalkDetailViewController {
      if let indexPath = collectionView.indexPathsForSelectedItems?[0] {
        vc.walkID = walks[indexPath.row].id
      }
    }
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

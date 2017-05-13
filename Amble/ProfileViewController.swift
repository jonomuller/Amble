//
//  ProfileViewController.swift
//  Amble
//
//  Created by Jono Muller on 20/02/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class ProfileViewController: UIViewController {
  
  @IBOutlet var statsView: StatsView!
  @IBOutlet var collectionView: UICollectionView!
  
  fileprivate var spinner: NVActivityIndicatorView!
  
  fileprivate var walks: [WalkInfo] = []
  fileprivate let WALK_CELL_IDENTIFIER = "WalkCell"
  fileprivate let CELLS_PER_ROW: CGFloat = 2
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setCustomBackButton(image: UIImage(named: "back-button"))
    self.statsView.distanceLabel.attributedText = Double(0).distanceLabelText()
    self.navigationItem.title = (User.sharedInstance.userInfo?.firstName)! + " " + (User.sharedInstance.userInfo?.lastName)!
    
    spinner = self.collectionView.createIndicatorView(width: 50, height: 50)
    spinner.startAnimating()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.getStats()
    self.getWalks { (walks) in
      if self.walks.count != walks.count {
        self.walks = walks
        self.collectionView.reloadData()
      }
    }
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
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d/M/yy"
    cell.dateLabel.text = dateFormatter.string(from: walk.date)
    
    cell.imageView.layer.cornerRadius = 8
    cell.imageView.clipsToBounds = true
    
    DispatchQueue.global().async {
      do {
        if let url = URL(string: walk.image) {
          let walkImage = try UIImage(data: Data(contentsOf: url))
          DispatchQueue.main.async(execute: {
            cell.imageView.image = walkImage
          })
        }
      } catch {
        print("Error fetching photo")
      }
    }
    
    return cell
  }
}

// MARK: - Collection view flow layout delegate

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = (view.frame.width - 20.0 * (CELLS_PER_ROW + 1)) / CELLS_PER_ROW
    let size = CGSize(width: cellWidth, height: cellWidth + 30)
    return size
  }
}

// MARK: - Navigation

extension ProfileViewController {
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? WalkDetailViewController {
      if let indexPath = collectionView.indexPath(for: sender as! WalkCollectionViewCell) {
        vc.walkID = walks[indexPath.row].id
      }
    }
   }
}

// MARK: - Private helper methods

private extension ProfileViewController {
  
  func getStats() {
    APIManager.sharedInstance.getInfo(id: (User.sharedInstance.userInfo?.id)!) { (response) in
      switch response {
      case .success(let json):
        DispatchQueue.main.async(execute: { 
          self.statsView.timeLabel.text = json["user"]["score"].stringValue
          self.statsView.distanceLabel.attributedText = json["user"]["distance"].doubleValue.distanceLabelText()
          self.statsView.stepsLabel.text = json["user"]["steps"].stringValue
        })
      case .failure(let error):
        self.displayErrorAlert(error: error)
      }
    }
  }
  
  func getWalks(completion: @escaping ([WalkInfo]) -> Void) {
    APIManager.sharedInstance.getWalks(id: (User.sharedInstance.userInfo?.id)!) { (response) in
      self.spinner.stopAnimating()
      switch response {
      case .success(let json):
        var walks: [WalkInfo] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        for (_, subJson): (String, JSON) in json["walks"] {
          let walk = WalkInfo(id: subJson["id"].stringValue,
                              name: subJson["name"].stringValue,
                              image: subJson["image"].stringValue,
                              date: dateFormatter.date(from: subJson["createdAt"].stringValue)!)
          walks.append(walk)
        }
        
        // Order walks by most to least recent
        walks = walks.sorted(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
        completion(walks)
      case .failure(let error):
        self.displayErrorAlert(error: error)
      }
    }
  }
}

//
//  PlaqueViewController.swift
//  Amble
//
//  Created by Jono Muller on 18/06/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class PlaqueViewController: UIViewController {
  
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var tableView: UITableView!
  
  var plaque: Plaque?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = plaque?.title
    imageView.contentMode = .scaleAspectFill
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    
    if plaque == nil {
      self.dismiss(animated: true, completion: nil)
    }
    
    DispatchQueue.global().async {
      do {
        if let imageURLString = self.plaque?.imageURL, let url = URL(string: imageURLString) {
          let plaqueImage = try UIImage(data: Data(contentsOf: url))
//          imageView.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
          DispatchQueue.main.async(execute: {
            self.imageView.image = plaqueImage
          })
        }
      } catch {
        print("Error fetching photo")
      }
    }
  }
}

// MARK: - Table view data source

extension PlaqueViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
//      let inscrip = NSString(string: plaque?.inscription!)
//      inscrip.size(
      return 80
    }
    
    return 44
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      return plaque!.people!.count
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Inscription"
    } else {
      return "People"
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaqueCell", for: indexPath)
    
    if indexPath.section == 0 {
      cell.textLabel?.text = plaque?.inscription
      cell.textLabel?.numberOfLines = 0
      cell.textLabel?.lineBreakMode = .byWordWrapping
      cell.accessoryType = .none
    } else {
      cell.accessoryType = .disclosureIndicator
      cell.textLabel?.text = plaque?.people?[indexPath.row]
    }
    
    return cell
  }
  
}

// MARK: - Action methods

extension PlaqueViewController {
  func doneButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
}


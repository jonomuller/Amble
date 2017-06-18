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
  
  var plaque: Plaque?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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

// MARK: - Action methods

extension PlaqueViewController {
  func doneButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
}


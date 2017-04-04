//
//  FirstViewController.swift
//  amble-ios
//
//  Created by Jono Muller on 20/02/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    APIManager.sharedInstance.login(with: ["username": "jonomuller", "password": "amble4lyfe"]) { (json, error) in
      if (error != nil) {
        print("Error: \(error!.localizedDescription)")
      } else {
        print("JWT: \(json["jwt"])")
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}


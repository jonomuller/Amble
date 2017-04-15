//
//  InitialViewController.swift
//  Amble
//
//  Created by Jono Muller on 15/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import ChameleonFramework

class InitialViewController: UIViewController {
  
  @IBOutlet var logo: UIImageView!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var registerButotn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = GradientColor(.topToBottom,
                                              frame: view.frame,
                                              colors: [.flatGreenDark, .flatForestGreen])
    
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: { 
      self.logo.transform = CGAffineTransform(translationX: 0, y: -150)
    }) { (finished) in
      self.loginButton.isHidden = false
      self.registerButotn.isHidden = false
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.makeTransparent()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
    
   }
 
  
}

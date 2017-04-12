//
//  LoginViewController.swift
//  Amble
//
//  Created by Jono Muller on 08/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import ChameleonFramework

class LoginViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var loginButton: LoginButton!
  
  fileprivate let LOGIN_CELL_IDENTIFIER = "loginCell"
  fileprivate let sections: [String] = ["username", "password"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = GradientColor(.topToBottom, frame: tableView.frame, colors: [.flatGreenDark, .flatForestGreen])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Bring up keyboard for first text field
    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LoginTableViewCell
    cell.textField.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // Set transparent navigation bar
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    
    // Call functions to animate the login button when the keyboard appears/disappears
    NotificationCenter.default.addObserver(loginButton, selector: #selector(loginButton.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(loginButton, selector: #selector(loginButton.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(loginButton)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

// MARK: - Table view data source

extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: LOGIN_CELL_IDENTIFIER, for: indexPath) as! LoginTableViewCell
    
    cell.selectionStyle = .none
    cell.line = CALayer()
    cell.updateBottomLine(selection: .deselect)
    cell.layer.addSublayer(cell.line)
    
    if indexPath.row == 0 {
      cell.setTextFieldImage(name: "user")
    } else if indexPath.row == sections.count - 1 {
      cell.setTextFieldImage(name: "padlock")
      cell.textField.returnKeyType = .go
      cell.textField.isSecureTextEntry = true
    }
    
    let checkmark = UIImage(named: "checkmark")
    cell.textField.rightView = UIImageView(image: checkmark)
    cell.textField.rightViewMode = .never
    
    cell.textField.attributedPlaceholder = NSAttributedString(string: sections[indexPath.row],
                                                              attributes: [NSForegroundColorAttributeName: UIColor.flatWhite])
    return cell
  }
}

// MARK: Scroll view delegate

extension LoginViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.endEditing(true)
  }
}

// MARK: - Text field delegate

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let indexPath = indexPathFromTextField(textField: textField)
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    cell.updateBottomLine(selection: .select)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let indexPath = indexPathFromTextField(textField: textField)
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    cell.updateBottomLine(selection: .deselect)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let indexPath = indexPathFromTextField(textField: textField)
    
    if indexPath.row < sections.count - 1 {
      let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
      let cell = tableView.cellForRow(at: nextIndexPath) as! LoginTableViewCell
      cell.textField.becomeFirstResponder()
    } else if noEmptyTextFields() {
      loginButtonPressed(self)
    }
    
    return false
  }
}

// MARK: IBAction methods

extension LoginViewController {
  
  @IBAction func loginButtonPressed(_ sender: Any) {
    loginButton.collapse() { (success) in
      let usernameCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LoginTableViewCell
      let passwordCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! LoginTableViewCell
      
      let username = usernameCell.textField.text
      let password = passwordCell.textField.text
      
      APIManager.sharedInstance.login(username: username!, password: password!) { (json, error) in
        self.loginButton.expand(completion: nil)
        
        if (error != nil) {
          let alertView = UIAlertController(title: "Log in error", message: error?.localizedDescription, preferredStyle: .alert)
          alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          self.present(alertView, animated: true, completion: nil)
        } else {
          let user = User(username: (json?["user"].stringValue)!, jwt: (json?["jwt"].stringValue)!)
          
          // Save user data to keychain
          do {
            try user.createInSecureStore()
            print("Login successful")
          } catch {
            print("Error saving to keychain: \(error)")
          }
          
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController")
          let navController = UINavigationController(rootViewController: vc)
          
          self.present(navController, animated: true, completion: nil)
        }
      }
    }
  }
  
  @IBAction func textFieldChanged(_ sender: Any) {
    // Enable login button if none of the text fields are empty
    loginButton.isEnabled = noEmptyTextFields()
    
    // Enable tick next to text field when not empty
    let indexPath = indexPathFromTextField(textField: sender as! UITextField)
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    if (cell.textField.text?.isEmpty)! {
      cell.textField.rightViewMode = .never
    } else {
      cell.textField.rightViewMode = .always
    }
  }
}

// MARK: Helper functions

extension LoginViewController {
  func noEmptyTextFields() -> Bool {
    var noEmptyCells = true
    
    // Check if any of the text fields are empty
    if let indexPaths = tableView.indexPathsForVisibleRows {
      for indexPath in indexPaths {
        let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
        if (cell.textField.text?.isEmpty)! {
          noEmptyCells = false
        }
      }
    }
    
    return noEmptyCells
  }
  
  func indexPathFromTextField(textField: UITextField) -> IndexPath {
    let location = textField.convert(textField.frame.origin, to: tableView)
    return tableView.indexPathForRow(at: location)!
  }
}

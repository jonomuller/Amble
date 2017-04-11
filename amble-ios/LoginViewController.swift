//
//  LoginViewController.swift
//  amble-ios
//
//  Created by Jono Muller on 08/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var loginButton: UIButton!
  
  let LOGIN_CELL_IDENTIFIER = "loginCell"
  let sections: [String] = ["username", "password"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.addKeyboardDismisser()
    loginButton.layer.cornerRadius = loginButton.frame.height / 2
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: IBAction methods
  
  @IBAction func loginButtonPressed(_ sender: Any) {
    let usernameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LoginTableViewCell
    let passwordCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! LoginTableViewCell
    
    let username = usernameCell.textField.text
    let password = passwordCell.textField.text
    
    APIManager.sharedInstance.login(username: username!, password: password!) { (json, error) in
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  // MARK: helper functions
  
  func updateBottomLine(cell: LoginTableViewCell, selection: Selection) {
    let height = selection.height
    cell.line.frame = CGRect(x: cell.innerView.frame.origin.x, y: cell.innerView.frame.size.height - height, width: cell.innerView.frame.size.width, height: height)
    cell.line.borderColor = selection.color
    cell.line.borderWidth = height
  }
  
  func keyboardChanged(notification: NSNotification) {
    if let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
      UIView.animate(withDuration: 0.1, animations: {
        self.loginButton.frame = CGRect(x: self.loginButton.frame.origin.x,
                                        y: keyboardRect.origin.y - self.loginButton.frame.height - 20,
                                        width: self.loginButton.frame.width,
                                        height: self.loginButton.frame.height)
      })
    }
  }
  
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
  
  func setTextFieldImage(cell: LoginTableViewCell, name: String) {
    let image = UIImage(named: name)
    let imageView = UIImageView(image: image)
    let padding = CGRect(x: 0, y: 0, width: imageView.frame.width + 15, height: imageView.frame.height)
    let paddingView = UIView(frame: padding)
    paddingView.addSubview(imageView)
    cell.textField.leftView = paddingView
    cell.textField.leftViewMode = .always
  }
}

// MARK: - Table view data source + delegate

extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: LOGIN_CELL_IDENTIFIER, for: indexPath) as! LoginTableViewCell
    
    cell.selectionStyle = .none
    cell.line = CALayer()
    updateBottomLine(cell: cell, selection: .deselect)
    cell.layer.addSublayer(cell.line)
    
    if indexPath.row == 0 {
      setTextFieldImage(cell: cell, name: "user")
    } else if indexPath.row == sections.count - 1 {
      setTextFieldImage(cell: cell, name: "padlock")
      cell.textField.returnKeyType = .go
      cell.textField.isSecureTextEntry = true
    }
    
    let checkmark = UIImage(named: "checkmark")
    cell.textField.rightView = UIImageView(image: checkmark)
    cell.textField.rightViewMode = .never
    
    cell.textField.attributedPlaceholder = NSAttributedString(string: sections[indexPath.row],
                                                              attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    cell.textField.becomeFirstResponder()
    updateBottomLine(cell: cell, selection: .select)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    cell.textField.resignFirstResponder()
    updateBottomLine(cell: cell, selection: .deselect)
  }
}

// MARK: - Text field delegate

extension LoginViewController: UITextFieldDelegate {
  
  func indexPathFromTextField(textField: UITextField) -> IndexPath {
    let location = textField.convert(textField.frame.origin, to: tableView)
    return tableView.indexPathForRow(at: location)!
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let indexPath = indexPathFromTextField(textField: textField)
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    updateBottomLine(cell: cell, selection: .select)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let indexPath = indexPathFromTextField(textField: textField)
    let cell = tableView.cellForRow(at: indexPath) as! LoginTableViewCell
    updateBottomLine(cell: cell, selection: .deselect)
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

// MARK: Custom view controller extensions

/*
 Extension to adjust the colour and thickness of the bottom line of a UITableViewCell
 */
extension UIViewController {
  enum Selection {
    case select
    case deselect
    
    var color: CGColor {
      switch self {
      case .select:
        return UIColor.white.cgColor
      case .deselect:
        return UIColor.lightGray.cgColor
      }
    }
    
    var height: CGFloat {
      switch self {
      case .select:
        return CGFloat(2.0)
      case .deselect:
        return CGFloat(1.0)
      }
    }
  }
}

/*
 Extension to dismiss the keyboard whenver the user presses off the keyboard anywhere on the view
 */
extension UIViewController {
  func addKeyboardDismisser() {
    let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    viewTap.cancelsTouchesInView = false
//    view.addGestureRecognizer(viewTap)
    
    let navTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    navTap.cancelsTouchesInView = false
//    self.navigationController?.navigationBar.addGestureRecognizer(navTap)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
}

//
//  LoginViewController.swift
//  amble-ios
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
    
    // Call functions to animate the login button when the keyboard appears/disappears
    NotificationCenter.default.addObserver(loginButton, selector: #selector(loginButton.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(loginButton, selector: #selector(loginButton.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    NotificationCenter.default.removeObserver(loginButton)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: IBAction methods
  
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
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.endEditing(true)
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
                                                              attributes: [NSForegroundColorAttributeName: UIColor.flatWhite])
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
        return UIColor.flatWhite.cgColor
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

extension UIButton {
  func setBackgroundColor(color: UIColor, forState: UIControlState) {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    
    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(color.cgColor)
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.setBackgroundImage(image, for: forState)
  }
}

extension UIButton {
  func keyboardWillShow(notification: NSNotification) {
    if let keyboardRectBegin = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
      if let keyboardRectEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
        if keyboardRectBegin != keyboardRectEnd {
          let transform = CGAffineTransform(translationX: 0, y: keyboardRectEnd.origin.y - self.frame.height - 20 - self.frame.origin.y)
          transformButton(transform: transform)
        }
      }
    }
  }
  
  func keyboardWillHide() {
    transformButton(transform: CGAffineTransform.identity)
  }
  
  private func transformButton(transform: CGAffineTransform) {
    UIView.animate(withDuration: 0.1, animations: {
      self.transform = transform
    })
  }
}

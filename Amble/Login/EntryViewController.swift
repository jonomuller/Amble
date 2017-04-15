//
//  EntryViewController.swift
//  Amble
//
//  Created by Jono Muller on 13/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import ChameleonFramework

/*
 Protocol for subclasses of EntryViewController to adopt
 Used to create custom login/register entry screens
 */
protocol EntryView {
  var sections: [String] { get }
  func entryButtonPressed(details: [String: String])
  func isValidTextField(textField: UITextField) -> Bool
}

class EntryViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var entryButton: EntryButton!
  
  fileprivate let ENTRY_CELL_IDENTIFIER = "entryCell"
  fileprivate let FAILURE_STRING = "This method must be overridden"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    entryButton.alpha = 0.7
    self.view.backgroundColor = GradientColor(.topToBottom,
                                              frame: view.frame,
                                              colors: [.flatGreenDark, .flatForestGreen])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Bring up keyboard for first text field
    if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EntryTableViewCell {
      cell.textField.becomeFirstResponder()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // Set transparent navigation bar
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    
    // Call functions to animate the login button when the keyboard appears/disappears
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let keyboardRectBegin = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
      if let keyboardRectEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: keyboardRectEnd.height + entryButton.frame.height + 30,
                                              right: 0)
        entryButton.keyboardWillShow(begin: keyboardRectBegin, end: keyboardRectEnd)
      }
    }
  }
  
  func keyboardWillHide() {
    tableView.contentInset = .zero
    entryButton.keyboardWillHide()
  }
}

// Mark: Entry protocol

extension EntryViewController: EntryView {
  
  var sections: [String] {
    preconditionFailure(FAILURE_STRING)
  }
  
  func entryButtonPressed(details: [String: String]) {
    preconditionFailure(FAILURE_STRING)
  }
  
  func isValidTextField(textField: UITextField) -> Bool {
    return !(textField.text?.isEmpty)!
  }
}

// MARK: - Table view data source + delegate

extension EntryViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ENTRY_CELL_IDENTIFIER, for: indexPath) as! EntryTableViewCell
    let section = sections[indexPath.row]
    
    cell.selectionStyle = .none
    cell.line = CALayer()
    cell.updateBottomLine(selection: .deselect)
    cell.layer.addSublayer(cell.line)
    cell.setTextFieldImage(name: section)
    
    if section == "email address" {
      cell.textField.keyboardType = .emailAddress
    } else if section == "password" {
      cell.textField.isSecureTextEntry = true
    }
    
    if indexPath.row == sections.count - 1 {
      cell.textField.returnKeyType = .go
    }
    
    let checkmark = UIImage(named: "checkmark")
    cell.textField.rightView = UIImageView(image: checkmark)
    cell.textField.rightViewMode = .never
    
    let color = UIColor.flatWhiteDark.lighten(byPercentage: 0.075)
    cell.textField.attributedPlaceholder = NSAttributedString(string: section,
                                                              attributes: [NSForegroundColorAttributeName: color!])
    
    return cell
  }
}

// MARK: - Scroll view delegate

extension EntryViewController: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.navigationController?.navigationBar.shadowImage = UIColor.flatWhite.generateImage()
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if targetContentOffset.pointee.y <= 0 {
      self.navigationController?.navigationBar.shadowImage = UIImage()
    }
  }
}

// MARK: - Text field delegate

extension EntryViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let indexPath = getIndexPathFromTextField(textField: textField)
    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    if let cell = tableView.cellForRow(at: indexPath) as? EntryTableViewCell {
      cell.updateBottomLine(selection: .select)
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let indexPath = getIndexPathFromTextField(textField: textField)
    if let cell = tableView.cellForRow(at: indexPath) as? EntryTableViewCell {
      cell.updateBottomLine(selection: .deselect)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let indexPath = getIndexPathFromTextField(textField: textField)
    
    if indexPath.row < sections.count - 1 {
      let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
      let cell = tableView.cellForRow(at: nextIndexPath) as! EntryTableViewCell
      cell.textField.becomeFirstResponder()
    } else if textFieldsAreValid() {
      entryButtonPressed(self)
    } else {
      textField.resignFirstResponder()
    }
    
    return false
  }
}

// MARK: - IBAction methods

extension EntryViewController {
  
  @IBAction func entryButtonPressed(_ sender: Any) {
    entryButton.collapse() { (success) in
      self.entryButtonPressed(details: self.getDataFromCells())
    }
  }
  
  @IBAction func textFieldChanged(_ sender: Any) {
    // Enable login button if none of the text fields are empty
    let validTextFields = textFieldsAreValid()
    entryButton.isEnabled = validTextFields
    if validTextFields {
      entryButton.alpha = 1
    } else {
      entryButton.alpha = 0.7
    }
    
    // Enable tick next to text field when not empty
    let indexPath = getIndexPathFromTextField(textField: sender as! UITextField)
    let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
    
    if isValidTextField(textField: cell.textField) {
      cell.textField.rightViewMode = .always
    } else {
      cell.textField.rightViewMode = .never
    }
  }
}

// MARK: - Public helper functions

extension EntryViewController {
  func handleAPIResponse(response: APIResponse) {
    entryButton.expand(completion: nil)
    
    switch response {
    case .success(let json):
      let user = User(username: (json["user"].stringValue), jwt: json["jwt"].stringValue)
      
      // Save user data to keychain
      do {
        try user.createInSecureStore()
      } catch {
        print("Error saving to keychain: \(error)")
      }
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController")
      let navController = UINavigationController(rootViewController: vc)
      
      self.present(navController, animated: true, completion: nil)
    case .failure(let error):
      let alertView = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .alert)
      alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alertView, animated: true, completion: nil)
    }
  }
}

// MARK: - Private helper functions

private extension EntryViewController {
  
  func getIndexPathFromTextField(textField: UITextField) -> IndexPath {
    let location = textField.convert(textField.frame.origin, to: tableView)
    return tableView.indexPathForRow(at: location)!
  }
  
  func textFieldsAreValid() -> Bool {
    var validCells = true
    
    if let indexPaths = tableView.indexPathsForVisibleRows {
      for indexPath in indexPaths {
        let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
        if !isValidTextField(textField: cell.textField) {
          validCells = false
        }
      }
    }
    
    return validCells
  }
  
  func getDataFromCells() -> [String: String] {
    var details: [String: String] = [:]
    
    if let indexPaths = tableView.indexPathsForVisibleRows {
      for indexPath in indexPaths {
        let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
        details[cell.textField.placeholder!] = cell.textField.text
      }
    }
    
    return details
  }
}

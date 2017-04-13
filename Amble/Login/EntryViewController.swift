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
  func entryButtonPressed()
  func textFieldsAreValid() -> Bool
}

class EntryViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var entryButton: EntryButton!
  
  fileprivate let ENTRY_CELL_IDENTIFIER = "entryCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = GradientColor(.topToBottom,
                                              frame: tableView.frame,
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
    NotificationCenter.default.addObserver(entryButton, selector: #selector(entryButton.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(entryButton, selector: #selector(entryButton.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(entryButton)
  }
  
  
}

// Mark: Entry protocol

extension EntryViewController: EntryView {
  
  var sections: [String] {
    preconditionFailure("This must be overriden")
  }
  
  func entryButtonPressed() {
    preconditionFailure("This must be overriden")
  }
  
  func textFieldsAreValid() -> Bool {
    preconditionFailure("This must be overidden")
  }
}

// MARK: - Table view data source + delegate

extension EntryViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ENTRY_CELL_IDENTIFIER, for: indexPath) as! EntryTableViewCell
    
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

extension EntryViewController: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.endEditing(true)
  }
}

// MARK: - Text field delegate

extension EntryViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let indexPath = getIndexPathFromTextField(textField: textField)
    let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
    cell.updateBottomLine(selection: .select)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let indexPath = getIndexPathFromTextField(textField: textField)
    let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
    cell.updateBottomLine(selection: .deselect)
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

// MARK: IBAction methods

extension EntryViewController {
  
  @IBAction func entryButtonPressed(_ sender: Any) {
    entryButton.collapse() { (success) in
      self.entryButtonPressed()
    }
  }
  
  @IBAction func textFieldChanged(_ sender: Any) {
    // Enable login button if none of the text fields are empty
    entryButton.isEnabled = textFieldsAreValid()
    
    // Enable tick next to text field when not empty
    let indexPath = getIndexPathFromTextField(textField: sender as! UITextField)
    let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
    if (cell.textField.text?.isEmpty)! {
      cell.textField.rightViewMode = .never
    } else {
      cell.textField.rightViewMode = .always
    }
  }
}

// MARK: Public helper functions

extension EntryViewController {
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

// MARK: Private helper functions

private extension EntryViewController {
  func getIndexPathFromTextField(textField: UITextField) -> IndexPath {
    let location = textField.convert(textField.frame.origin, to: tableView)
    return tableView.indexPathForRow(at: location)!
  }
}

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
  
  let sections: [String] = ["username", "password"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loginButton.layer.cornerRadius = loginButton.frame.size.height / 2
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Bring up keyboard for first text field
    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LoginTableViewCell
    cell.textField.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  func updateBottomLine(cell: LoginTableViewCell, selection: Selection) {
    let height = selection.height
    cell.line.frame = CGRect(x: 0, y: cell.frame.size.height - height, width: cell.frame.size.width, height: height)
    cell.line.borderColor = selection.color
    cell.line.borderWidth = height
  }
  
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


extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! LoginTableViewCell
    
    cell.selectionStyle = .none
    cell.line = CALayer()
    updateBottomLine(cell: cell, selection: .deselect)
    cell.layer.addSublayer(cell.line)
    
    if indexPath.row == sections.count - 1 {
      cell.textField.returnKeyType = .go
    }
    
    cell.textField.attributedPlaceholder = NSAttributedString(string: sections[indexPath.row],
                                                              attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
//    cell.textField.placeholder = sections[indexPath.row]
    
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

extension LoginViewController: UITextFieldDelegate {
  
  func getCellFromTextField(textField: UITextField) -> LoginTableViewCell {
    let location = textField.convert(textField.frame.origin, to: tableView)
    let indexPath = tableView.indexPathForRow(at: location)
    return tableView.cellForRow(at: indexPath!) as! LoginTableViewCell
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let cell = getCellFromTextField(textField: textField)
    updateBottomLine(cell: cell, selection: .select)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let cell = getCellFromTextField(textField: textField)
    updateBottomLine(cell: cell, selection: .deselect)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let location = textField.convert(textField.frame.origin, to: tableView)
    let indexPath = tableView.indexPathForRow(at: location)
    
    if (indexPath?.row)! < sections.count - 1 {
      let nextIndexPath = IndexPath(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
      let cell = tableView.cellForRow(at: nextIndexPath) as! LoginTableViewCell
      cell.textField.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    return false
  }
  
}

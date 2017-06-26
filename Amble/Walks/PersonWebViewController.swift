//
//  PersonWebViewController.swift
//  Amble
//
//  Created by Jono Muller on 23/06/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PersonWebViewController: UIViewController {
  
  @IBOutlet var webView: UIWebView!
  @IBOutlet var toolbar: UIToolbar!
  
  var url: URL!
  var name: String!
  
  fileprivate var spinner: NVActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = name
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let openButton = UIBarButtonItem(title: "Open in Safari", style: .done, target: self, action: #selector(openInSafari))
    
    toolbar.items = [flexibleSpace, openButton]
    
    webView.loadRequest(URLRequest(url: url))
    spinner = self.view.createIndicatorView(width: 50, height: 50)
    spinner.startAnimating()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

// MARK: Web view delegate

extension PersonWebViewController: UIWebViewDelegate {
  func webViewDidFinishLoad(_ webView: UIWebView) {
    spinner.stopAnimating()
  }
}

// MARK: - Action methods

extension PersonWebViewController {
  
  func doneButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
  
  func openInSafari() {
    if let url = webView.request?.url {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}

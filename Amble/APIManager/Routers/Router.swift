//
//  Router.swift
//  Amble
//
//  Created by Jono Muller on 25/05/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import Alamofire

protocol Router: URLRequestConvertible {
  static var baseURLPath: String { get }
  var method: HTTPMethod { get }
  var path: String { get }
  var parameters: [String: Any] { get }
}

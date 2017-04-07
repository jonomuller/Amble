//
//  APIManagerTests.swift
//  amble-ios
//
//  Created by Jono Muller on 04/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import amble_ios

class APIManagerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: POST /login
  
  func testLoginWithDetailsMissingReturnsError() {
    let exp = expectation(description: "POST /login no details")
    
    APIManager.sharedInstance.login(username: "", password: "password") { (json, error) in
      XCTAssertNil(json, "JSON is not nil")
      XCTAssertNotNil(error, "Error is nil")
      XCTAssert(error?.localizedDescription == "Please enter your username.")
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  // MARK: POST /register
  
  func testRegisterWithDetailsMissingReturnsError() {
    let exp = expectation(description: "POST /register no details")
    
    APIManager.sharedInstance.register(username: "bob", email: "", password: "password", firstName: "Bob", lastName: "Bobson") { (json, error) in
      XCTAssertNil(json, "JSON is not nil")
      XCTAssertNotNil(error, "Error is nil")
      XCTAssert(error?.localizedDescription == "Please enter your email.")
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}

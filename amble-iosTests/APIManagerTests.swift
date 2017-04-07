//
//  APIManagerTests.swift
//  amble-ios
//
//  Created by Jono Muller on 04/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import XCTest
import SwiftyJSON
import Mockingjay
@testable import amble_ios

class APIManagerTests: XCTestCase {
  
  struct TestUser {
    var username: String
    var email: String
    var password: String
    var firstName: String
    var lastName: String
  }
  
  var testUser: TestUser!
  
  override func setUp() {
    super.setUp()
    testUser = TestUser(username: "bob123", email: "bob@bobson.com", password: "amble4lyfe", firstName: "Bob", lastName: "Bobson")
  }
  
  override func tearDown() {
    testUser = nil
    super.tearDown()
  }
  
  // MARK: POST /login
  
  func testValidLogin() {
    // Mock API call to return successful login
    let matcher = http(.post, uri: Router.baseURLPath + "/auth/login")
    let builder = json(["success": "true",
                        "user": testUser.username,
                        "jwt": "_jwt"], status: 200, headers: [:])
    
    stub(matcher, builder)
    
    let exp = expectation(description: "POST /login valid")
    
    APIManager.sharedInstance.login(username: testUser.username, password: testUser.password) { (json, error) in
      XCTAssertNotNil(json, "JSON is nil")
      XCTAssertNil(error, "Error is not nil")
      XCTAssertTrue((json?["success"].boolValue)!, "Success value is false")
      XCTAssertEqual(json?["user"].stringValue, self.testUser.username, "User returned is not the same")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testLoginWithMissingDetailsReturnsError() {
    let exp = expectation(description: "POST /login no details")
    
    APIManager.sharedInstance.login(username: "", password: testUser.username) { (json, error) in
      XCTAssertNil(json, "JSON is not nil")
      XCTAssertNotNil(error, "Error is nil")
      XCTAssertEqual(error?.localizedDescription, "Please enter your username.", "Incorrect error message")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  
  // MARK: POST /register
  
  func testValidRegister() {
    // Mock API call to return successful registration
    let matcher = http(.post, uri: Router.baseURLPath + "/auth/register")
    let builder = json(["success": "true",
                        "user": testUser.username,
                        "jwt": "_jwt"], status: 201, headers: [:])
    
    stub(matcher, builder)
    
    let exp = expectation(description: "POST /register valid")
    
    APIManager.sharedInstance.register(username: testUser.username, email: testUser.email, password: testUser.password, firstName: testUser.firstName, lastName: testUser.lastName) { (json, error) in
      XCTAssertNotNil(json, "JSON is nil")
      XCTAssertNil(error, "Error is not nil")
      XCTAssertTrue((json?["success"].boolValue)!, "Success value is false")
      XCTAssertEqual(json?["user"].stringValue, self.testUser.username, "User returned is not the same")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testRegisterWithMissingDetailsReturnsError() {
    let exp = expectation(description: "POST /register no details")
    
    APIManager.sharedInstance.register(username: testUser.username, email: "", password: testUser.password, firstName: testUser.firstName, lastName: testUser.lastName) { (json, error) in
      XCTAssertNil(json, "JSON is not nil")
      XCTAssertNotNil(error, "Error is nil")
      XCTAssertEqual(error?.localizedDescription, "Please enter your email.", "Incorrect error message")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
}

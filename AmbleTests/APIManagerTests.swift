//
//  APIManagerTests.swift
//  Amble
//
//  Created by Jono Muller on 04/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import XCTest
import SwiftyJSON
import Mockingjay
@testable import Amble

class APIManagerTests: XCTestCase {
  
  struct TestUser {
    var username: String
    var email: String
    var password: String
    var firstName: String
    var lastName: String
  }
  
  var testUser: TestUser!
  var mockedResponse: ([String: String])!
  
  override func setUp() {
    super.setUp()
    testUser = TestUser(username: "bob123",
                        email: "bob@bobson.com",
                        password: "amble4lyfe",
                        firstName: "Bob",
                        lastName: "Bobson")
    
    mockedResponse = ["success": "true",
                      "user": testUser.username,
                      "jwt": "_jwt"]
  }
  
  override func tearDown() {
    testUser = nil
    mockedResponse = nil
    super.tearDown()
  }
  
  // MARK: POST /login
  
  func testValidLogin() {
    // Mock API call to return successful login
    let matcher = http(.post, uri: Router.baseURLPath + "/auth/login")
    let builder = json(mockedResponse, status: 200, headers: [:])
    
    stub(matcher, builder)
    
    let exp = expectation(description: "POST /login valid")
    
    APIManager.sharedInstance.login(username: testUser.username, password: testUser.password) { (response) in
      XCTAssertTrue(response.success, "Response is false")
      let json = response.value as! JSON
      
      XCTAssertNotNil(json, "JSON is nil")
      XCTAssertTrue((json["success"].boolValue), "Success value is false")
      XCTAssertEqual(json["user"].stringValue, self.testUser.username, "User returned is not the same")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testLoginWithMissingDetailsReturnsError() {
    let exp = expectation(description: "POST /login no details")
    
    APIManager.sharedInstance.login(username: "", password: testUser.username) { (response) in
      XCTAssertFalse(response.success, "Response is true")
      let error = response.value as! NSError
      
      XCTAssertNotNil(error, "Error is nil")
      XCTAssertEqual(error.localizedDescription, "Please enter your username.", "Incorrect error message")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  
  // MARK: POST /register
  
  func testValidRegister() {
    // Mock API call to return successful registration
    let matcher = http(.post, uri: Router.baseURLPath + "/auth/register")
    let builder = json(mockedResponse, status: 201, headers: [:])
    
    stub(matcher, builder)
    
    let exp = expectation(description: "POST /register valid")
    
    APIManager.sharedInstance.register(username: testUser.username, email: testUser.email, password: testUser.password, firstName: testUser.firstName, lastName: testUser.lastName) { (response) in
      XCTAssertTrue(response.success, "Response is false")
      let json = response.value as! JSON
      
      XCTAssertNotNil(json, "JSON is nil")
      XCTAssertTrue((json["success"].boolValue), "Success value is false")
      XCTAssertEqual(json["user"].stringValue, self.testUser.username, "User returned is not the same")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testRegisterWithMissingDetailsReturnsError() {
    let exp = expectation(description: "POST /register no details")
    
    APIManager.sharedInstance.register(username: testUser.username, email: "", password: testUser.password, firstName: testUser.firstName, lastName: testUser.lastName) { (response) in
      XCTAssertFalse(response.success, "Response is true")
      let error = response.value as! NSError
      
      XCTAssertNotNil(error, "Error is nil")
      XCTAssertEqual(error.localizedDescription, "Please enter your email.", "Incorrect error message")
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
}

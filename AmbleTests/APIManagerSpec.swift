//
//  APIManagerSpec.swift
//  Amble
//
//  Created by Jono Muller on 04/04/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON
import Mockingjay

@testable import Amble

class APIManagerSpec: QuickSpec {
  
  override func spec() {
    
    struct TestUser {
      var username: String
      var email: String
      var password: String
      var firstName: String
      var lastName: String
    }
    
    var testUser: TestUser!
    var mockedResponse: ([String: String])!
    var apiResponse: APIResponse?
    var json: JSON?
    var error: NSError?
    
    beforeEach {
      testUser = TestUser(username: "bob123",
                          email: "bob@bobson.com",
                          password: "amble4lyfe",
                          firstName: "Bob",
                          lastName: "Bobson")
      
      mockedResponse = ["success": "true",
                        "user": testUser.username,
                        "jwt": "_jwt"]
    }
    
    
    describe("POST login") {
      context("valid") {
        it("should log user in and return JWT") {
          // Mock API call to return successful login
          let matcher = http(.post, uri: AmbleRouter.baseURLPath + "/auth/login")
          let builder = Mockingjay.json(mockedResponse, status: 200, headers: [:])
          
          self.stub(matcher, builder)
          
          waitUntil(timeout: 60.0) { (done) in
            APIManager.sharedInstance.login(username: testUser.username, password: testUser.password) { (response) in
              apiResponse = response
              json = response.value as? JSON
              done()
            }
          }
          
          expect(apiResponse?.success).toEventually(beTrue())
          expect(json).toNotEventually(beNil())
          expect(json?["success"].boolValue).toEventually(beTrue())
          expect(json?["user"].stringValue).toEventually(equal(testUser.username))
        }
      }
      
      context("invalid") {
        it("returns error") {
          waitUntil(timeout: 60.0) { (done) in
            APIManager.sharedInstance.login(username: "", password: testUser.username) { (response) in
              apiResponse = response
              error = response.value as? NSError
              done()
            }
          }
          
          expect(apiResponse?.success).toNotEventually(beTrue())
          expect(error).toNotEventually(beNil())
          expect(error?.localizedDescription).toEventually(equal("Please enter your username."))
        }
      }
    }
    
    describe("POST register") {
      context("valid") {
        it("should register user and return JWT") {
          // Mock API call to return successful registration
          let matcher = http(.post, uri: AmbleRouter.baseURLPath + "/auth/register")
          let builder = Mockingjay.json(mockedResponse, status: 201, headers: [:])
          
          self.stub(matcher, builder)
          
          waitUntil(timeout: 60.0) { (done) in
            APIManager.sharedInstance.register(username: testUser.username, email: testUser.email, password: testUser.password, firstName: testUser.firstName, lastName: testUser.lastName) { (response) in
              apiResponse = response
              json = response.value as? JSON
              done()
            }
          }
          
          expect(apiResponse?.success).toEventually(beTrue())
          expect(json).toNotEventually(beNil())
          expect(json?["success"].boolValue).toEventually(beTrue())
          expect(json?["user"].stringValue).toEventually(equal(testUser.username))
        }
      }
      
      context("invalid") {
        it("returns error") {
          waitUntil(timeout: 60.0) { (done) in
            APIManager.sharedInstance.register(username: testUser.username, email: "", password: testUser.password, firstName: testUser.firstName, lastName: testUser.lastName) { (response) in
              apiResponse = response
              error = response.value as? NSError
              done()
            }
          }
          
          expect(apiResponse?.success).toNotEventually(beTrue())
          expect(error).toNotEventually(beNil())
          expect(error?.localizedDescription).toEventually(equal("Please enter your email."))
        }
      }
    }
    
    afterEach {
      testUser = nil
      mockedResponse = nil
      apiResponse = nil
      json = nil
      error = nil
    }
  }
}

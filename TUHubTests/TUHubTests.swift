//
//  TUHubTests.swift
//  TUHubTests
//
//  Created by Connor Crawford on 2/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import XCTest
@testable import TUHub

class TUHubTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGrades() {
        let asyncExpectation = expectation(description: "testGrades")
        var kGrades: [Term]?
        var kUser: User?
        
        User.signInSilently { (user, error) in
            if let user = user {
                kUser = user
                user.retrieveGrades({ (grades, error) in
                    if let grades = grades {
                        kGrades = grades
                    }
                    asyncExpectation.fulfill()
                })
            }
        }

        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kUser, "Failed to retrieve user.\nSign in if you have not already done so.")
            XCTAssertNotNil(kGrades, "Failed to retrieve grades for user.")
        }
    }
    
    func testCourseOverview() {
        let asyncExpectation = expectation(description: "testCourseOverview")
        var kTerms: [Term]?
        var kUser: User?
        
        User.signInSilently { (user, error) in
            if let user = user {
                kUser = user
                user.retrieveCourses({ (terms, error) in
                    kTerms = terms
                    asyncExpectation.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kUser, "Failed to retrieve user.\nSign in if you have not already done so.")
            XCTAssertNotNil(kTerms, "Failed to retrieve course overview for user.")
        }

    }
    
    func testCourseRoster() {
        let asyncExpectation = expectation(description: "testCourseCalendarView")
        var kRoster: [String]?
        var kUser: User?
        
        User.signInSilently { (user, error) in
            if let user = user {
                kUser = user
                user.retrieveCourses({ (terms, error) in
                    if let course = terms?.first?.courses.first {
                        course.retrieveRoster({ (roster, error) in
                            kRoster = roster
                            asyncExpectation.fulfill()
                        })
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kUser, "Failed to retrieve user.\nSign in if you have not already done so.")
            XCTAssertNotNil(kRoster, "Failed to retrieve course roster for user.")
        }
        
    }
    
    
    func testCourseSearch() {
        let asyncExpectation = expectation(description: "testCourseSearch")
        
        var kResults: [CourseSearchResult]?
        
        CourseSearchResult.search(for: "Project", pageNumber: 0) { (results, error) in
            kResults = results
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            
            XCTAssertNotNil(kResults, "Failed to retrieve course search results.")
            
            if let error = error {
                log.error(error)
            }
        }
        
    }
    
//    func testJobsOfUser() {
//        let asyncExpectation = expectation(description: "testCourseSearch")
//        
//        Job.retrieve
//        
//    }
    
// MARK: MarketPlace

    func testMarketplaceUser() {
        
        let asyncExpectation = expectation(description: "testMarketplaceUser")
        var kMarketUser: MarketplaceUser?
        
        MarketplaceUser.retrieve(user: "tue68553") { (user, error) in
            kMarketUser = user
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kMarketUser, "Failed to retrieve user.\nSign in if you have not already done so.")
        }
        
    }
    
    // Don't know how to test this, it's always saying "Test Succed" even though I entered wrong user ID
    func testRetrieveProduct() {
        
        let asyncExpectation = expectation(description: "testRetrieveProduct")
        var kProduct: [Product]?

        Product.retrieve(belongingTo: "123") { (products, error) in
            kProduct = products
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kProduct, "Failed to retrieve product for the user")
        }
        
    }
    
    // Don't know how to test this, it's always saying "Test Succed" even though I entered wrong user ID
    func testRetrievePersonal() {
        let asyncExpectation = expectation(description: "testRetrievePersonal")
        var kPersonal: [Personal]?
        
        Personal.retrieve(belongingTo: "123") { (personal, error) in
            kPersonal = personal
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kPersonal, "Failed to retrieve product for the user")
        }
        
    }

}

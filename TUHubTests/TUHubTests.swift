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
        
        CourseSearchResult.search(for: "psych", pageNumber: 0) { (results, error) in
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
    
}

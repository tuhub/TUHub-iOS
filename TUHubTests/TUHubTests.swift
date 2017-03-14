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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
        var kCourses: [Term]?
        var kUser: User?
        
        User.signInSilently { (user, error) in
            if let user = user {
                kUser = user
                user.retrieveCourseOverview({ (courses, error) in
                    if let courses = courses {
                        kCourses = courses
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
            XCTAssertNotNil(kCourses, "Failed to retrieve course overview for user.")
        }

    }
    
    func testCourseFullView() {
        let asyncExpectation = expectation(description: "testCourseFullView")
        var kCourses: [Term]?
        var kUser: User?
        
        User.signInSilently { (user, error) in
            if let user = user {
                kUser = user
                user.retrieveCourseFullView({ (courses, error) in
                    if let courses = courses {
                        kCourses = courses
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
            XCTAssertNotNil(kCourses, "Failed to retrieve course full view for user.")
        }
        
    }

    // CourseCalendarView only provides data about the current week, which we are unlikely to need because we will be providing a full calendar
//    func testCourseCalendarView() {
//        let asyncExpectation = expectation(description: "testCourseCalendarView")
//        var kCourses: [Term]?
//        var kUser: User?
//        
//        User.signInSilently { (user, error) in
//            if let user = user {
//                kUser = user
//                user.retrieveCourseCalendarView({ (courses, error) in
//                    if let courses = courses {
//                        kCourses = courses
//                    }
//                    asyncExpectation.fulfill()
//                })
//            }
//        }
//        
//        waitForExpectations(timeout: 10) { (error) in
//            if let error = error {
//                log.error(error)
//            }
//            
//            XCTAssertNotNil(kUser, "Failed to retrieve user.\nSign in if you have not already done so.")
//            XCTAssertNotNil(kCourses, "Failed to retrieve course calendar view for user.")
//        }
//        
//    }
    
    func testCourseRoster() {
        let asyncExpectation = expectation(description: "testCourseCalendarView")
        var kRoster: [String]?
        var kUser: User?
        
        User.signInSilently { (user, error) in
            if let user = user {
                kUser = user
                user.retrieveCourseOverview({ (terms, error) in
                    if let course = terms?.first?.courses?.first {
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
    
}

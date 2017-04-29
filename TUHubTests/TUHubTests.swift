//
//  TUHubTests.swift
//  TUHubTests
//
//  Created by Connor Crawford on 2/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import XCTest
import YelpAPI
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
    
    // MARK: - Temple API
    
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
    
    func testRetrieveBuildings() {
        let asyncExpectation = expectation(description: "testRetrieveBuildings")
        var kCampuses: [Campus]?
        
        Campus.retrieveAll { (campuses, error) in
            kCampuses = campuses
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kCampuses, "Failed to retrieve buildings")
        }
    }
    
    func testRetrieveNews() {
        let asyncExpectation = expectation(description: "testRetrieveNews")
        var kItems: [NewsItem]?
        
        NewsItem.retrieve(fromFeeds: NewsItem.Feed.allValues) { (items, error) in
            if let error = error {
                log.error(error)
            }
            kItems = items
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kItems, "Failed to retrieve news items")
        }
    }

    // MARK: Marketplace

    func testRetrieveUser() {
        
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
            
            XCTAssertNotNil(kMarketUser, "Failed to retrieve user.")
        }
        
    }
    
    func testRetrieveProduct() {
        
        let asyncExpectation = expectation(description: "testRetrieveProduct")
        var kProduct: [Product]?

        Product.retrieveAll { (products, error) in
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
            
            XCTAssertNotNil(kProduct, "Failed to retrieve products")
        }
        
    }
    
    func testRetrieveJob() {
        
        let asyncExpectation = expectation(description: "testRetrieveJob")
        var kJobs: [Job]?
        
        Job.retrieveAll { (jobs, error) in
            kJobs = jobs
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kJobs, "Failed to retrieve jobs")
        }
        
    }
    
    func testRetrievePersonal() {
        let asyncExpectation = expectation(description: "testRetrievePersonal")
        var kPersonal: [Personal]?
        
        Personal.retrieveAll { (personal, error) in
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
            
            XCTAssertNotNil(kPersonal, "Failed to retrieve personals")
        }
        
    }
    
}

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
        
        CourseSearchResult.search(for: "ios", pageNumber: 0) { (results, error) in
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
    
    // MARK: Product
    
    func testRetrieveProduct() {
        
        let asyncExpectation = expectation(description: "testRetrieveProduct")
        var kProduct: [Product]?

        Product.retrieveAll { (products, error) in
            kProduct = products
            
            for product in kProduct! {
                debugPrint("Result: \(product.title)")
            }
            
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
    
    func testPostProduct() {
        let asyncExpectation = expectation(description: "testPostProduct")
        var kListing: Listing?
        
        kListing = Product(title: "Product Unit Test", desc: "Test", ownerID: "tue68553", photosDir: nil, price: 2.00)
        
        kListing?.post({ (product, error) in
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kListing, "Failed to post listing")
        }
    }
    
    // MARK: Personal
    
    func testRetrievePersonal() {
        let asyncExpectation = expectation(description: "testRetrievePersonal")
        var kPersonal: [Personal]?
        
        Personal.retrieveAll { (personal, error) in
            kPersonal = personal
            
            for personal in kPersonal! {
                debugPrint("Result: \(personal.title)")
            }
            
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
    
    func testSearchPersonal() {
        let asyncExpectation = expectation(description: "testSearchPersonal")
        var kPersonal: [Personal]?
        
        Personal.search(for: "Study", startIndex: 0) { (result, error) in
            kPersonal = result
            
            for personal in kPersonal! {
                debugPrint("Result: \(personal.title)")
            }
            
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kPersonal, "Failed to retrieve personal search result")
        }
        
    }
    
    func testPostPersonal() {
        let asyncExpectation = expectation(description: "testPostPersonal")
        var kListing: Listing?
        
        kListing = Personal(title: "Personal Unit Test", desc: "Test", ownerID: "tue68553", photosDir: nil, location: nil)
        
        kListing?.post({ (product, error) in
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kListing, "Failed to post personal")
        }
    }
    
    
    // MARK: Job
    
    func testJobsOfUser() {
        let asyncExpectation = expectation(description: "testJobsOfUser")
        
        var kJobs: [Job]?
        
        Job.retrieve(belongingTo: "tue68553") { (jobs, error) in
            kJobs = jobs
            
            for job in kJobs! {
                debugPrint("Result: \(job.title)")
            }
            
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
            
        }
        
        waitForExpectations(timeout: 30) { (error) in
            
            XCTAssertNotNil(kJobs, "Failed to retrieve jobs.")
            
            if let error = error {
                log.error(error)
            }
        }
    }
    
    func testSearchJob() {
        let asyncExpectation = expectation(description: "testSearchJob")
        var kJob: [Job]?
        
        Job.search(for: "Window", startIndex: 0) { (result, error) in
            kJob = result
            
            for job in kJob! {
                debugPrint("Result: \(job.title)")
            }
            
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kJob, "Failed to retrieve job search result")
        }
        
    }
    
    func testPostJob() {
        let asyncExpectation = expectation(description: "testPostJob")
        var kListing: Listing?
        let currentDate = Date()
        
        kListing = Job(title: "Job Unit Test", desc: "Test", ownerID: "tue68553", photosDir: nil, location: "Job", hours: 0, pay: 2.00, startDate: currentDate)

        kListing?.post({ (job, error) in
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kListing, "Failed to post job")
        }
    }

// MARK: NewsItem
    
    func testRetrieveNewsFeed() {
        let asyncExpectation = expectation(description: "testRetrieveNewsFeed")

        var kNewsItem: [NewsItem]?

        NewsItem.retrieve(fromFeeds: [NewsItem.Feed.students]) { (newsFeed, error) in
            
            kNewsItem = newsFeed
            for feed in kNewsItem! {
                debugPrint("Result: \(feed.title)")
            }
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()

        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kNewsItem, "Failed to retrieve news feed")
        }
    }
    
    // MARK: Campus
    
    func testRetrieveCampus() {
        let asyncExpectation = expectation(description: "testRetrieveNewsFeed")
        var kCampus:[Campus]?
        
        Campus.retrieveAll { (campus, error) in
            
            kCampus = campus
            for campus in kCampus! {
                debugPrint("Result: \(campus.name)")
            }
            
            if let error = error {
                log.error(error)
            }
            asyncExpectation.fulfill()
        }
        

        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            
            XCTAssertNotNil(kCampus, "Failed to retrieve all the campus")
        }

    }

    func testImageUpload() {
        let asyncExpectation = expectation(description: "uploadImage")
        
        let images: [UIImage] = [#imageLiteral(resourceName: "TransitIcon"), #imageLiteral(resourceName: "CarIcon")]
        var kError: Error?
        
        Listing.upload(images: images, toFolder: "test123") { (error) in
            if let error = error {
                log.error(error)
            }
            kError = error
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                log.error(error)
            }
            XCTAssertNil(kError, "Image upload unsuccessful")
        }
    }

}


//  User.swift
//  TUHub
//
//  Created by Connor Crawford on 2/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Alamofire
import SwiftyJSON

// Fake values for protection space so URLSession does not actually use stored credential
// If real values are used, a bug will occur that prevents the user from switching accounts for ~10 seconds
fileprivate let protectionSpace = URLProtectionSpace(host: "prd-mobile.temple.edu",
                                                            port: 0,
                                                            protocol: nil,
                                                            realm: nil,
                                                            authenticationMethod: nil)

// Real values, if I can ever figure out the URLCredential bug
//    private static let protectionSpace = URLProtectionSpace(host: "prd-mobile.temple.edu",
//                                                     port: 443,
//                                                     protocol: "https",
//                                                     realm: "Mobile Integration Server banner-mobileserver",
//                                                     authenticationMethod: NSURLAuthenticationMethodHTTPBasic)

class User {
    
    static internal var current: User?
    private(set) var username: String
    private(set) var tuID: String
    private(set) var roles: [String]
    fileprivate(set) var credential: Credential
    var terms: [Term]?
    
    
    internal init?(json: JSON, credential: Credential) {
        
        if let username = json["authId"].string,
            let tuID = json["userId"].string,
            let roles = json["roles"].array?.map({$0.stringValue}) {
            
            self.username = username
            self.tuID = tuID
            self.roles = roles
            
            self.credential = credential
        } else {
            return nil
        }
        
    }
    
}

// MARK: - Authentication
extension User {
    
    typealias UserResponseHandler = (User?, Error?) -> Void
    
    static func signIn(username: String, password: String, _ responseHandler: UserResponseHandler?) {
        
        let credential = Credential(username: username, password: password)
        
        NetworkManager.shared.request(fromEndpoint: .getUserInfo, authenticateWith: credential) { (data, error) in
            
            defer {
                responseHandler?(User.current, error)
            }
            
            // Turn raw data into JSON
            guard let data = data else { return }
            let json = JSON(data)
            
            if let user = User(json: json, credential: credential) {
                // Success, so store credential in keychain
                let credential = URLCredential(user: username, password: password, persistence: .permanent)
                URLCredentialStorage.shared.set(credential, for: protectionSpace)
                
                User.current = user
                
                log.verbose("User signed in\nUsername: \(user.username)\nTUID: \(user.tuID)\n")
            }
            
        }
        
    }
    
    static func signInSilently(_ responseHandler: UserResponseHandler?) {
        
        guard let urlCredential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace),
            let username = urlCredential.user,
            let password = urlCredential.password
            else {
                responseHandler?(nil, nil)
                return
        }
        
        let credential = Credential(username: username, password: password)
        NetworkManager.shared.request(fromEndpoint: .getUserInfo, authenticateWith: credential) { (data, error) in
            
            // Respond with values when leaving scope
            defer { responseHandler?(User.current, error) }
            
            // Turn raw data into JSON
            guard let data = data else { return }
            let json = JSON(data)
            
            if let user = User(json: json, credential: credential) {
                User.current = user
                log.verbose("User signed in\nUsername: \(user.username)\nTUID: \(user.tuID)\n")
            }
            
        }
        
    }
    
    static func signOut() {
        
        User.current = nil
        
        // Clear stored credentials
        for (protectionSpace, keyPair) in URLCredentialStorage.shared.allCredentials {
            for (_, credential) in keyPair {
                URLCredentialStorage.shared.remove(credential, for: protectionSpace)
            }
        }
        
        Alamofire.SessionManager.default.session.reset {}
        
    }
    
}

// MARK: - Grades
extension User {
    
    typealias GradesResponseHandler = ([Term]?, Error?) -> Void
    
    func retrieveGrades(_ responseHandler: GradesResponseHandler?) {
        
        NetworkManager.shared.request(fromEndpoint: .grades, pathParameters: [tuID], authenticateWith: credential) { (data, error) in
            
            var grades: [Term]?
            
            if let data = data {
                let json = JSON(data)
                
                for (_, subJSON) in json["terms"] {
                    if let term = Term(json: subJSON) {
                        if grades == nil {
                            grades = [Term]()
                        }
                        grades!.append(term)
                    }
                }
            }
            
            responseHandler?(grades, error)
        }
        
    }
    
}

// MARK: - Courses
extension User {
    
    typealias CoursesResponseHandler = ([Term]?, Error?) -> Void
    
    func retrieveCourses(_ responseHandler: CoursesResponseHandler?) {
        NetworkManager.shared.request(fromEndpoint: .courseOverview, pathParameters: [tuID], authenticateWith: credential) { (data, error) in
            
            var courseTerms = [Term]()
            
            // Respond when leaving scope
            defer { responseHandler?(courseTerms.count > 0 ? courseTerms : nil, error) }
            
            guard let data = data else { return }
            let json = JSON(data)
            
            // Parse JSON into terms
            for (_, subJSON) in json["terms"] {
                if let term = Term(json: subJSON) {
                    courseTerms.append(term)
                }
            }
            
            // Retrieve grades and associate with their corresponding course
            self.retrieveGrades() { (gradeTerms, error) in
                guard var gradeTerms = gradeTerms else {
                        responseHandler?(courseTerms, error)
                        return
                }
                var courseTerms = courseTerms.sorted { $0.startDate > $1.startDate }
                gradeTerms.sort(by: { $0.startDate > $1.startDate })
                
                for (index, gradeTerm) in gradeTerms.enumerated() {
                    
                    // Get each corresponding term's courses
                    
                    let courses = courseTerms[index].courses.sorted(by: { $0.sectionID < $1.sectionID })
                    let gradeCourses = gradeTerm.courses.sorted(by: { $0.sectionID < $1.sectionID })
                    for (i, gradeCourse) in gradeCourses.enumerated() {
                        courses[i].grades = gradeCourse.grades
                    }
                    courseTerms[index].courses = courses
                }
                
                self.terms = courseTerms
            }
        }
    }
    
    func search(for searchText: String, _ responseHandler: @escaping ([Term]?) -> Void) {
        guard var terms = terms else {
            responseHandler(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var results = [Term]()
            let searchTerm = searchText.capitalized
            
            // Sort the terms from most to least recent
            terms.sort(by: { $0.startDate > $1.startDate })
            
            for term in terms {

                // The term to hold the results
                var term = term
                
                var courseResults: [(course: Course, index: String.Index)] = []
                for course in term.courses {
                    
                    // Find the lowest index at which the occurence of the search term appeared
                    var minIndex: String.Index?
                    if let index = course.name.capitalized.index(of: searchTerm) {
                        minIndex = index
                    }
                    if let index = course.title.capitalized.index(of: searchTerm) {
                        if minIndex == nil || index < minIndex! {
                            minIndex = index
                        }
                    }
                    if let index = course.description?.capitalized.index(of: searchTerm) {
                        if minIndex == nil || index < minIndex! {
                            minIndex = index
                        }
                    }
                    
                    // Append the result if the term appeared
                    if let minIndex = minIndex {
                        courseResults.append((course: course, index: minIndex))
                    }
                }
                
                // Sort the results by increasing index, as a lower index means a closer match
                courseResults.sort(by: { $0.index < $1.index })
                
                // Replace term's courses with results
                let courses: [Course] = courseResults.map { $0.course }
                if courses.count > 0 {
                    term.courses = courses
                    results.append(term)
                }
                
            }
            
            // Go back to main thread and return the results
            DispatchQueue.main.async {
                responseHandler(results)
            }
            
        }
        
    }
    
}

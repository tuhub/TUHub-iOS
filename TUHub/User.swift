
//  User.swift
//  TUHub
//
//  Created by Connor Crawford on 2/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Alamofire
import SwiftyJSON

// Fake values for protection space so URLSession does not actually use stored credential
// If real values are used, a bug will occur that prevents the user from switching accounts for 10 seconds
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
        
        NetworkManager.request(fromEndpoint: .getUserInfo, authenticateWith: credential) { (json, error) in
            // Attempt to unwrap necessary attributes
            if let json = json, let user = User(json: json, credential: credential) {
                
                // Success, so store credential in keychain
                let credential = URLCredential(user: username, password: password, persistence: .permanent)
                URLCredentialStorage.shared.set(credential, for: protectionSpace)
                
                User.current = user
                
                log.verbose("User signed in\nUsername: \(user.username)\nTUID: \(user.tuID)\n")
            }
            
            responseHandler?(User.current, error)
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
        NetworkManager.request(fromEndpoint: .getUserInfo, authenticateWith: credential) { (json, error) in
            // Attempt to unwrap necessary attributes
            if let json = json, let user = User(json: json, credential: credential) {
                debugPrint(json)
                User.current = user
                
                log.verbose("User signed in\nUsername: \(user.username)\nTUID: \(user.tuID)\n")
            }
            
            responseHandler?(User.current, error)
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
    
    fileprivate func retrieveGrades(_ responseHandler: GradesResponseHandler?) {
        
        NetworkManager.request(fromEndpoint: .grades, withTUID: tuID, authenticateWith: credential) { (json, error) in
            
            var grades: [Term]?
            
            if let json = json {
                debugPrint(json)
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

// Courses
extension User {
    
    typealias CoursesResponseHandler = ([Term]?, Error?) -> Void
    
    func retrieveCourseOverview(_ responseHandler: CoursesResponseHandler?) {
        NetworkManager.request(fromEndpoint: .courseOverview, withTUID: tuID, authenticateWith: credential) { (json, error) in
            
            guard let json = json else {
                responseHandler?(nil, error)
                return
            }
            
            var courseTerms = [Term]()
            
            // Parse JSON into terms
            for (_, subJSON) in json["terms"] {
                if let term = Term(json: subJSON) {
                    courseTerms.append(term)
                }
            }
            
            // Retrieve grades and associate with their corresponding course
            self.retrieveGrades({ (gradeTerms, error) in
                guard let gradeTerms = gradeTerms else {
                        responseHandler?(courseTerms, error)
                        return
                }
                var courseTerms = courseTerms
                
                for gradeTerm in gradeTerms {
                    
                    // Get each corresponding term's courses
                    guard let grades = gradeTerm.grades,
                        let index = courseTerms.index(where: { $0.id == gradeTerm.id }),
                        var courses = courseTerms[index].courses else { continue }
                    
                    // Find the corresponding course for the grade
                    for grade in grades {
                        guard let index = courses.index(where: {$0.sectionID == grade.sectionID}) else { continue }
                        var course = courses[index]
                        
                        // Add the grade to the course's grades
                        if course.grades == nil {
                            course.grades = [grade]
                        } else {
                            course.grades!.append(grade)
                        }
                        courses[index] = course
                    }
                    
                    courseTerms[index].courses = courses
                    
                }
                
                responseHandler?(courseTerms, error)
            })
        }
    }
    
//    func retrieveCourseFullView(_ responseHandler: CoursesResponseHandler?) {
//        NetworkManager.request(fromEndpoint: .courseFullView, withTUID: tuID, authenticateWith: credential) { (json, error) in
//            var courses: [Term]?
//            
//            if let json = json {
//                for (_, subJSON) in json["terms"] {
//                    if let term = Term(json: subJSON) {
//                        if courses == nil {
//                            courses = [Term]()
//                        }
//                        courses!.append(term)
//                    }
//                }
//            }
//            responseHandler?(courses, error)
//        }
//    }
    
    // CourseCalendarView only provides data about the current week, which we are unlikely to need because we will be providing a full calendar
//    func retrieveCourseCalendarView(_ responseHandler: CoursesResponseHandler?) {
//        NetworkManager.request(fromEndpoint: .courseCalendarView, withTUID: tuID, authenticateWith: credential) { (json, error) in
//            var courses: [Course]?
//            
//            if let json = json {
//                debugPrint(json)
//            }
//            
//        }
//    }
    
}

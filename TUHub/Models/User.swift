
//  User.swift
//  TUHub
//
//  Created by Connor Crawford on 2/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Alamofire
import SwiftyJSON
import EventKit

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

fileprivate let calendarKey = "calendar"

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
        MarketplaceUser.current = nil
        
        // Clear stored credentials
        for (protectionSpace, keyPair) in URLCredentialStorage.shared.allCredentials {
            for (_, credential) in keyPair {
                URLCredentialStorage.shared.remove(credential, for: protectionSpace)
            }
        }
        
        // Clear all defaults
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
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
            self.retrieveGrades { (gradeTerms, error) in
                guard var gradeTerms = gradeTerms else {
                        responseHandler?(courseTerms, error)
                        return
                }
                let courseTerms = courseTerms.sorted { $0.startDate > $1.startDate }
                gradeTerms.sort(by: { $0.startDate > $1.startDate })
                
                for gradeTerm in gradeTerms {
                    // Find the matching semester in the list of semesters
                    guard let matchingTerm = courseTerms.first(where: { $0.id == gradeTerm.id }) else { continue }
                    
                    for gradeCourse in gradeTerm.courses {
                        // Find the matching course in the semester's list of courses
                        guard let matchingCourse = matchingTerm.courses.first(where: { $0.sectionID == gradeCourse.sectionID }) else { continue }
                        matchingCourse.grades = gradeCourse.grades
                    }
                    
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
    
    static func exportCoursesToCalendar(_ viewController: UIViewController) {
        
        func showUnableToExport() {
            let alert = UIAlertController(title: "Unable to Export Courses", message: "TUHub was unable to export your courses. Please grant TUHub permission to use Calendars and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
        
        guard let user = User.current else { return }
        
        func export(meetings: [CourseMeeting], eventStore: EKEventStore, calendar: EKCalendar) {
            let event = EKEvent(eventStore: eventStore)
            for meeting in meetings {
                event.calendar = calendar
                event.title = meeting.course.description ?? meeting.course.name
                event.startDate = meeting.firstMeetingStartDate
                event.endDate = meeting.firstMeetingEndDate
                event.availability = .busy
                event.location = "\(meeting.buildingName) \(meeting.room)"
                
                let daysOfWeek: [EKRecurrenceDayOfWeek] = meeting.daysOfWeek.flatMap {
                    if let weekday = EKWeekday(rawValue: $0) {
                        return EKRecurrenceDayOfWeek(weekday)
                    }
                    return nil
                }
                let end = EKRecurrenceEnd(end: meeting.lastMeetingEndDate)
                let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly,
                                                      interval: 1,
                                                      daysOfTheWeek: daysOfWeek,
                                                      daysOfTheMonth: nil,
                                                      monthsOfTheYear: nil,
                                                      weeksOfTheYear: nil,
                                                      daysOfTheYear: nil,
                                                      setPositions: nil,
                                                      end: end)
                event.addRecurrenceRule(recurrenceRule)
                
                try? eventStore.save(event, span: .thisEvent)
            }
            try? eventStore.commit()
        }
        
        func export(terms: [Term]) {
            let eventStore = EKEventStore()
            let authStatus = EKEventStore.authorizationStatus(for: .event)
            
            func getCalendarAndExport(terms: [Term]) {
                var calendar: EKCalendar!
                let defaults = UserDefaults.standard
                if let id = defaults.string(forKey: calendarKey), let cal = eventStore.calendar(withIdentifier: id) {
                    calendar = cal
                } else {
                    calendar = EKCalendar(for: .event, eventStore: eventStore)
                    calendar.title = "My Classes"
                    calendar.cgColor = UIColor.cherry.cgColor
                    
                    // Save the calendar's ID to user defaults
                    let id = calendar.calendarIdentifier
                    defaults.set(id, forKey: calendarKey)
                    do {
                        if let source = eventStore.sources.first(where: { $0.sourceType == .calDAV }) ?? eventStore.sources.first(where: { $0.sourceType == .local }) {
                            calendar.source = source
                        } else {
                            let error = NSError(domain: String(describing: MoreTableViewController.self), code: -1, userInfo: nil)
                            throw error
                        }
                        try eventStore.saveCalendar(calendar, commit: true)
                    } catch {
                        log.error("Unable to save calendar: " + error.localizedDescription)
                        showUnableToExport()
                        return
                    }
                }
                
                for term in terms {
                    for course in term.courses {
                        if let meetings = course.meetings {
                            export(meetings: meetings, eventStore: eventStore, calendar: calendar)
                        }
                    }
                }
                
                // All done!
                let alert = UIAlertController(title: "Courses Exported", message: "Your courses have been exported to the Calendar app. Go check it out!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                viewController.present(alert, animated: true, completion: nil)
            }
            
            if authStatus == .denied || authStatus == .restricted {
                showUnableToExport()
            } else if authStatus == .notDetermined {
                eventStore.requestAccess(to: .event) { (_, _) in
                    getCalendarAndExport(terms: terms)
                }
            } else {
                getCalendarAndExport(terms: terms)
            }
            
        }
        
        if let terms = user.terms {
            export(terms: terms)
        } else {
            user.retrieveCourses { (terms, error) in
                if let terms = terms {
                    export(terms: terms)
                }
            }
        }
    }
    
}

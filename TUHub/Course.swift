//
//  Course.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct Course {
    
    let name: String // Course code
    let description: String? // Longest name
    let title: String // Shorter than description
    let sectionID: String
    let sectionNumber: String
    let credits: UInt8?
    let termID: String
    private(set) var meetings: [CourseMeeting]? // Presumably, an online class has no meetings?
    private(set) var instructors: [Instructor]? // Not provided in fullview or calendar view
    let levels: [String]?
    var roster: [String]?
    
    init?(json: JSON, termID: String) {
        guard let name = json["courseName"].string,
            let title = json["sectionTitle"].string,
            let sectionID = json["sectionId"].string,
            let sectionNumber = json["courseSectionNumber"].string
            else {
                log.error("Invalid JSON while initializing Course")
                return nil
        }
        
        self.termID = termID
        self.name = name
        self.description = json["courseDescription"].string
        self.title = title
        self.sectionID = sectionID
        self.sectionNumber = sectionNumber
        self.credits = json["credits"].uInt8
        self.levels = json["academicLevels"].arrayObject as? [String]
        
        if let instructorsJSON = json["instructors"].array {
            for subJSON in instructorsJSON {
                if let instructor = Instructor(json: subJSON) {
                    if instructors == nil {
                        instructors = [Instructor]()
                    }
                    instructors!.append(instructor)
                }
            }
        }
        
        if let meetingPatterns = json["meetingPatterns"].array {
            for subJSON in meetingPatterns {
                if let meeting = CourseMeeting(json: subJSON, course: self) {
                    if meetings == nil {
                        meetings = [CourseMeeting]()
                    }
                    meetings!.append(meeting)
                }
            }
            meetings?.sort { $0.startDate < $1.startDate }
        }
        
    }
    
}

extension Course {
    
    typealias RosterResponseHandler = ([String]?, Error?) -> Void
    
    func retrieveRoster(_ responseHandler: RosterResponseHandler?) {
        guard let user = User.current else {
            log.error("Attempting to retrieve roster when user is not authenticated.")
            return
        }
        
        let args = ["term=\(termID)", "section=\(sectionID)"]
        NetworkManager.request(fromEndpoint: .courseRoster, withTUID: user.tuID, arguments: args, authenticateWith: user.credential) { (json, error) in
            
            var roster: [String]?
            
            if let json = json {
                
                var names = [String]()
                if let values = json["activeStudents"].array {
                    for value in values {
                        if let name = value["name"].string {
                            names.append(name)
                        }
                    }
                }
                
                if names.count > 0 {
                    roster = names
                }
                
            }
            
            responseHandler?(roster, error)
            
        }
    }
    
}

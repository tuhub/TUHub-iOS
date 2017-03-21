//
//  Course.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

class Course {
    /// Course code
    let name: String
    /// Longest name
    let description: String?
    /// Shorter than description
    let title: String
    let sectionID: String
    let sectionNumber: String
    let credits: UInt8?
    let termID: String
    private(set) var meetings: [CourseMeeting]? // Presumably, an online class has no meetings?
    private(set) var instructors: [Instructor]? // Not provided in fullview or calendar view
    let levels: [String]?
    var roster: [String]?
    var grades: [Grade]?
    let startDate: Date?
    let endDate: Date?
    
    
    init?(json: JSON, termID: String) {
        guard
            let name = json["courseName"].string,
            let title = json["sectionTitle"].string,
            let sectionID = json["sectionId"].string,
            let sectionNumber = json["courseSectionNumber"].string,
            let credits = json["credits"].uInt8 ?? UInt8(json["creditHours"].string ?? "")
            else {
                log.error("Invalid JSON while initializing Course")
                return nil
        }
        
        // Assign mandatory properties
        self.termID = termID
        self.name = name
        self.title = title
        self.sectionID = sectionID
        self.sectionNumber = sectionNumber
        self.credits = credits
        
        // Attempt to assign optional properties
        description = json["courseDescription"].string
        levels = json["academicLevels"].arrayObject as? [String]
        startDate = json["firstMeetingDate"].date
        endDate = json["lastMeetingDate"].date

        // Attempt to map JSON arrays
        instructors = json["instructors"].array?.flatMap({ Instructor(json: $0) })
        meetings = json["meetingPatterns"].array?.flatMap({ CourseMeeting(json: $0, course: self) }).sorted { $0.startDate < $1.startDate }
        grades = json["grades"].array?.flatMap { Grade(json: $0, course: self) }
        
    }
    
}

// MARK: - Roster
extension Course {
    
    typealias RosterResponseHandler = ([String]?, Error?) -> Void
    
    func retrieveRoster(_ responseHandler: RosterResponseHandler?) {
        guard let user = User.current else {
            log.error("Attempting to retrieve roster when user is not authenticated.")
            return
        }
        
        let params = ["term" : termID, "section" : sectionID]
        NetworkManager.shared.request(fromEndpoint: .courseRoster, withTUID: user.tuID, parameters: params, authenticateWith: user.credential) { (data, error) in
            
            var roster: [String]?
            
            defer { responseHandler?(roster, error) }
            guard let data = data else { return }
            let json = JSON(data)
            
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
            
            self.roster = roster
            
        }
    }
    
}

//
//  Grade.swift
//  TUHub
//
//  Created by Connor Crawford on 2/17/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct Grade {
    
    private(set) var courseName: String
    private(set) var sectionID: String
    private(set) var sectionTitle: String
    private(set) var creditHours: String
    private(set) var courseSectionNumber: String
    private(set) var grade: String
    private(set) var updated: Date
    
    init?(json: JSON) {
        
        guard let courseName = json["courseName"].string,
            let sectionID = json["sectionId"].string,
            let sectionTitle = json["sectionTitle"].string,
            let creditHours = json["creditHours"].string,
            let courseSectionNumber = json["courseSectionNumber"].string,
            let grades = json["grades"].array?.first?.dictionary,
            let grade = grades["value"]?.string,
            let updated = grades["updated"]?.dateTime
            else {
                log.error("Invalid JSON while initializing Grade")
                return nil
        }
        
        self.courseName = courseName
        self.sectionID = sectionID
        self.sectionTitle = sectionTitle
        self.creditHours = creditHours
        self.courseSectionNumber = courseSectionNumber
        self.grade = grade
        self.updated = updated
    }
    
}

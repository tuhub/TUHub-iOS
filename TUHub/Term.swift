//
//  Term.swift
//  TUHub
//
//  Created by Connor Crawford on 2/17/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct Term {
    
    private(set) var id: String
    private(set) var name: String
    private(set) var startDate: Date
    private(set) var endDate: Date
    private(set) var grades: [Grade]?
    var courses: [Course]?
    
    init?(json: JSON) {
        
        guard let id = json["id"].string,
            let name = json["name"].string,
            let startDate = json["startDate"].date,
            let endDate = json["endDate"].date,
            let sections = json["sections"].array
            else {
                log.error("Invalid JSON while initializing Term")
                return nil
        }
        
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        
        for subJSON in sections {
            // Check whether the JSON contains grade or course info
            
            // For grades
            if subJSON["grades"] != JSON.null {
                if let grade = Grade(json: subJSON) {
                    if grades == nil {
                        grades = [Grade]()
                    }
                    grades!.append(grade)
                }
            }
            // For course overview
            else if subJSON["meetingPatterns"] != JSON.null {
                if let course = Course(json: subJSON, termID: id) {
                    if courses == nil {
                        courses = [Course]()
                    }
                    courses!.append(course)
                }
            }
            // For course full view
            else if subJSON["sectionId"] != JSON.null {
                if let course = Course(json: subJSON, termID: id) {
                    if courses == nil {
                        courses = [Course]()
                    }
                    courses!.append(course)
                }
            }
        }
    }
    
}

extension Term: Hashable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Term, rhs: Term) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return id.hash
    }
    
}

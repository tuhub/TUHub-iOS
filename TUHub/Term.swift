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
    var courses: [Course]
    
    init?(json: JSON) {
        
        guard let id = json["id"].string,
            let name = json["name"].string,
            let startDate = json["startDate"].date,
            let endDate = json["endDate"].date,
            let courses = json["sections"].array?.flatMap({ Course(json: $0, termID: id) })
            else {
                log.error("Invalid JSON while initializing Term")
                return nil
        }
        
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.courses = courses
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
        return id.hashValue
    }
    
}

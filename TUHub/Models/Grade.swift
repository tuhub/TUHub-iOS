//
//  Grade.swift
//  TUHub
//
//  Created by Connor Crawford on 2/17/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct Grade {
    
    private(set) var name: String
    private(set) var grade: String
    private(set) var updated: Date
    
    init?(json: JSON, course: Course) {
        
        guard
            let name = json["name"].string,
            let grade = json["value"].string,
            let updated = json["updated"].dateTime
            else {
                log.error("Invalid JSON while initializing Grade")
                return nil
        }
        
        self.name = name
        self.grade = grade
        self.updated = updated
    }
    
}

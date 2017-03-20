//
//  Instructor.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct Instructor {
    let firstName: String
    let middleName: String?
    let lastName: String
    let formattedName: String
    let instructorID: String
    let isPrimary: Bool
    
    init?(json: JSON) {
        
        guard let firstName = json["firstName"].string,
            let lastName = json["lastName"].string,
            let formattedName = json["formattedName"].string,
            let instructorID = json["instructorId"].string,
            let isPrimary = json["primary"].string
            else {
                log.error("Invalid JSON while initializing Instructor")
                return nil
        }
        
        self.firstName = firstName
        self.middleName = json["middleInitial"].string
        self.lastName = lastName
        self.formattedName = formattedName
        self.instructorID = instructorID
        self.isPrimary = isPrimary == "true" ? true : false
    }

}

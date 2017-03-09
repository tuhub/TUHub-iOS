//
//  CourseMeeting.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct CourseMeeting {

    let daysOfWeek: [Int]
    let buildingID: String
    let buildingName: String
    let room: String
    let startTime: String
    let endTime: String
    
    init?(json: JSON) {
        guard let daysOfWeek = json["daysOfWeek"].arrayObject as? [Int],
            let buildingID = json["buildingId"].string,
            let buildingName = json["building"].string,
            let room = json["room"].string,
            let startTime = json["startTime"].string,
            let endTime = json["endTime"].string
            else {
                log.error("Invalid JSON while initializing CourseMeeting")
                return nil
        }
        
        self.daysOfWeek = daysOfWeek
        self.buildingID = buildingID
        self.buildingName = buildingName
        self.room = room
        self.startTime = startTime
        self.endTime = endTime
        
    }
}

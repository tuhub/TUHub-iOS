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
    var startTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: startDate)
    }
    let startDate: Date
    var endTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: endDate)
    }
    let endDate: Date
    var course: Course
    
    init?(json: JSON, course: Course) {
        guard let daysOfWeek = json["daysOfWeek"].arrayObject as? [Int],
            let buildingID = json["buildingId"].string,
            let buildingName = json["building"].string,
            let room = json["room"].string,
            let startTimeStr = json["startTime"].string,
            let startDateStr = json["startDate"].string,
            let endTimeStr = json["endTime"].string,
            let endDateStr = json["endDate"].string,
            let startDate = (startDateStr + "T" + startTimeStr).dateTime,
            let endDate = (endDateStr + "T" + endTimeStr).dateTime
            else {
                log.error("Invalid JSON while initializing CourseMeeting")
                return nil
        }
        self.daysOfWeek = daysOfWeek
        self.buildingID = buildingID
        self.buildingName = buildingName
        self.room = room
        self.startDate = startDate
        self.endDate = endDate
        self.course = course
    }
}

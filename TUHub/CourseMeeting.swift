//
//  CourseMeeting.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct CourseMeeting {

    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = .autoupdatingCurrent
        return dateFormatter
    }()
    
    var course: Course
    let daysOfWeek: [Int]
    let buildingID: String
    let buildingName: String
    let room: String
    let startDate: Date
    let endDate: Date
    var endTime: String {
        return CourseMeeting.dateFormatter.string(from: endDate)
    }
    var startTime: String {
        return CourseMeeting.dateFormatter.string(from: startDate)
    }
    
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
        self.course = course
        
        // Temple API assumes non-daylight savings time, so need to remove offset if there is one
        let timezone = TimeZone.autoupdatingCurrent
        self.startDate = startDate - timezone.daylightSavingTimeOffset(for: startDate)
        self.endDate = endDate - timezone.daylightSavingTimeOffset(for: endDate)

    }
}

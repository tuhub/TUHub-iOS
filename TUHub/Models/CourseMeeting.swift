//
//  CourseMeeting.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

private var timeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    dateFormatter.timeZone = .autoupdatingCurrent
    return dateFormatter
}()

private var calendar = Calendar.autoupdatingCurrent

struct CourseMeeting {
    
    var course: Course
    let daysOfWeek: [Int]
    let buildingID: String
    let buildingName: String
    let room: String
    let firstMeetingStartDate: Date
    let lastMeetingEndDate: Date
    lazy var durationComponents: DateComponents = {
        let components: Set<Calendar.Component> = [.day, .hour, .minute]
        var dateComponents = calendar.dateComponents(components, from: self.firstMeetingStartDate, to: self.lastMeetingEndDate)
        dateComponents = DateComponents(hour: dateComponents.hour, minute: dateComponents.minute)
        return dateComponents
    }()
    lazy var firstMeetingEndDate: Date = {
        return calendar.date(byAdding: self.durationComponents, to: self.firstMeetingStartDate)!
    }()
    lazy var lastMeetingStartDate: Date = {
        var dateComponents = self.durationComponents
        dateComponents = DateComponents(hour: -dateComponents.hour!, minute: -dateComponents.minute!)
        return calendar.date(byAdding: dateComponents, to: self.lastMeetingEndDate)!
    }()
    
    init?(json: JSON, course: Course) {
        guard let daysOfWeek = json["daysOfWeek"].arrayObject?.map({ ($0 as! Int) - 1 }),
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
        self.firstMeetingStartDate = startDate - timezone.daylightSavingTimeOffset(for: startDate)
        self.lastMeetingEndDate = endDate - timezone.daylightSavingTimeOffset(for: endDate)
    }
}

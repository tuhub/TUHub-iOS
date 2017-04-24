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

class CourseMeeting {
    
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
    lazy var startTime: Time = {
       return Time(calendar.dateComponents([.hour, .minute, .second], from: self.firstMeetingStartDate))!
    }()
    lazy var endTime: Time = {
        return Time(calendar.dateComponents([.hour, .minute, .second], from: self.firstMeetingEndDate))!
    }()
    
    init?(json: JSON, course: Course) {
        guard let daysOfWeek = (json["daysOfWeek"].arrayObject as? [Int])?.sorted(),
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
        
        // Adjust start date to real first day of the meetings, not the first day of the semester (unless that is the actual date of the first meeting)
        var startComponents = calendar.dateComponents([.weekday, .hour, .minute], from: startDate)
        var realFirstMeetingDate: Date = startDate
        if !daysOfWeek.contains(startComponents.weekday!) {
            startComponents.weekday = daysOfWeek.first(where: { $0 > startComponents.weekday! })
            realFirstMeetingDate = calendar.nextDate(after: startDate, matching: startComponents, matchingPolicy: .nextTime)!
        }
        
        // Temple API assumes non-daylight savings time, so need to remove offset if there is one
        let timezone = TimeZone.autoupdatingCurrent
        self.firstMeetingStartDate = realFirstMeetingDate - timezone.daylightSavingTimeOffset(for: realFirstMeetingDate)
        self.lastMeetingEndDate = endDate - timezone.daylightSavingTimeOffset(for: endDate)
    }
}

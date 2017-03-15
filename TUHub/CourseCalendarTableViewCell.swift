//
//  CourseCalendarTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/15/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    func setUp(from courseMeeting: CourseMeeting) {
        startTimeLabel.text = courseMeeting.startTime
        endTimeLabel.text = courseMeeting.endTime
        nameLabel.text = courseMeeting.course.title
        locationLabel.text = "\(courseMeeting.buildingName) \(courseMeeting.room)"
    }

}

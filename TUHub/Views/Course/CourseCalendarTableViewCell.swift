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
    @IBOutlet weak var separator: UIView!

    // Needed to prevent the separator from changing colors during selection
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.separator.backgroundColor // Store the color
        super.setHighlighted(highlighted, animated: animated)
        self.separator.backgroundColor = color
    }
    
    // Needed to prevent the separator from changing colors during selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.separator.backgroundColor // Store the color
        super.setSelected(selected, animated: animated)
        self.separator.backgroundColor = color
    }
    
    func setUp(from courseMeeting: CourseMeeting) {
        startTimeLabel.text = courseMeeting.firstMeetingStartDate.time
        endTimeLabel.text = courseMeeting.firstMeetingEndDate.time
        nameLabel.text = courseMeeting.course.title
        locationLabel.text = "\(courseMeeting.buildingName) \(courseMeeting.room)"
    }

}

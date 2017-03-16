//
//  CourseDetailHeaderTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/16/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseDetailHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func setUp(from course: Course) {
        // Format the start and end dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let startDateStr = dateFormatter.string(from: course.startDate)
        let endDateStr = dateFormatter.string(from: course.endDate)
        
        titleLabel.text = course.description ?? course.title
        subtitleLabel.text = "\(startDateStr) to \(endDateStr)"
    }

}

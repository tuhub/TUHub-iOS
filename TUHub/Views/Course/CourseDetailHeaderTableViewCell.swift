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
    
        titleLabel.text = course.description ?? course.title
        
        if let startDate = course.startDate, let endDate = course.endDate {
            // Format the start and end dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let startDateStr = dateFormatter.string(from: startDate)
            let endDateStr = dateFormatter.string(from: endDate)
            subtitleLabel.text = "\(startDateStr) to \(endDateStr)"
        }
    }

}

//
//  HoursTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI

private let timeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter
}()

class HoursTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
    func setUp(with hours: [YLPHours], isExpanded: Bool) {
        
        let calendar = Calendar.autoupdatingCurrent
        let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
        
        separatorHeight.constant = 1 / UIScreen.main.scale
        
        expandButton.setTitle(isExpanded ? "Show Today" : "Show All", for: .normal)
        expandButton.sizeToFit()
        
        leftLabel.text = ""
        rightLabel.text = ""

        if isExpanded {
            
            let weekdaySymbols = calendar.weekdaySymbols
            
            for (i, weekday) in weekdaySymbols.enumerated() {
                
                leftLabel.text! += weekday
                
                // Yelp uses Monday as the first day, while Apple uses Sunday. Move Sunday from first to last spot
                // Do some fancy maths to make shift the days accordingly
                let yelpIndex = (i + 6) % 7
                
                if let dayIndex = hours.index(where: { Int($0.day) == yelpIndex }) {
                    let day = hours[dayIndex]
                    
                    if let startDate = calendar.date(byAdding: day.startTimeComponents, to: referenceDate), let endDate = calendar.date(byAdding: day.endTimeComponents, to: referenceDate) {
                        rightLabel.text! += timeFormatter.string(from: startDate) + " - " + timeFormatter.string(from: endDate)
                    }
                }
                else {
                    rightLabel.text! += "Closed"
                }
                
                if i < weekdaySymbols.count - 1 {
                    leftLabel.text! += "\n"
                    rightLabel.text! += "\n"
                }
                
            }
            
        } else {
            leftLabel.text = "Today"
            
            if let dayOfWeek = calendar.dateComponents([.weekday], from: Date()).weekday, let i = hours.index(where: { Int($0.day) == (dayOfWeek + 5) % 7 }) {
                let today = hours[i]
                let startDate = calendar.date(byAdding: today.startTimeComponents, to: referenceDate)!
                let endDate = calendar.date(byAdding: today.endTimeComponents, to: referenceDate)!
                rightLabel.text! = timeFormatter.string(from: startDate) + " - " + timeFormatter.string(from: endDate)
            } else {
                rightLabel.text = "Closed"
            }
            
        }
    }

}

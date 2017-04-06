//
//  CourseTableViewDataSource.swift
//  TUHub
//
//  Created by Connor Crawford on 4/5/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseTableViewDataSource: NSObject, UITableViewDataSource {
    
    var course: Course
    
    init(course: Course) {
        self.course = course
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 3
        if course.grades != nil {
            numberOfSections += 1
        }
        if course.roster != nil {
            numberOfSections += 1
        }
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return 1
        case 1:
            return course.meetings?.count ?? 0
        case 2:
            return course.instructors?.count ?? 0
        case 3:
            // Section 3 can either be grades or roster, depending on if grades are available
            return course.grades?.count ?? course.roster?.count ?? 0
        case 4:
            return course.roster?.count ?? 0
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 1:
            return "Meeting Times"
        case 2:
            return "Faculty"
        case 3:
            return course.grades != nil ? "Grades" : "Roster"
        case 4:
            return "Roster"
            
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.section {
            
        case 0:
            cell = tableView.dequeueReusableCell(withType: .headerCell, for: indexPath)
            
            (cell as? CourseDetailHeaderTableViewCell)?.setUp(from: course)
            
        // Meeting Times
        case 1:
            cell = tableView.dequeueReusableCell(withType: .subtitleCell, for: indexPath)
            
            if let meeting = course.meetings?[indexPath.row] {
                
                // Generate the names of the days in which the meetings occur
                let daysOfWeek = meeting.daysOfWeek
                let weekdaySymbols = Calendar.current.shortWeekdaySymbols
                var str = ""
                for (i, day) in daysOfWeek.enumerated() {
                    str += weekdaySymbols[day - 1]
                    if i != daysOfWeek.count - 1 {
                        str += ", "
                    }
                }
                
                cell.textLabel?.text = str + ": \(meeting.startTime) to \(meeting.endTime)"
                cell.detailTextLabel?.text = "\(meeting.buildingName), Room \(meeting.room)"
            }
            
        // Faculty
        case 2:
            cell = tableView.dequeueReusableCell(withType: .basicCell, for: indexPath)
            
            if let instructor = course.instructors?[indexPath.row] {
                cell.textLabel?.text = instructor.formattedName
            }
            
        // Roster or grades
        case 3:
            
            cell = tableView.dequeueReusableCell(withType: .subtitleCell, for: indexPath)
            
            // Try grades first
            if let grade = course.grades?[indexPath.row] {
                
                // Get the formatted date string
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let dateString = dateFormatter.string(from: grade.updated)
                
                cell.textLabel?.text = grade.grade
                cell.detailTextLabel?.text = "\(grade.name) | Updated: \(dateString)"
            }
                // Try roster
            else {
                fallthrough
            }
            
            
        // Roster
        case 4:
            cell = tableView.dequeueReusableCell(withType: .basicCell, for: indexPath)
            
            if let student = course.roster?[indexPath.row] {
                cell.textLabel?.text = student
            }
            
        default:
            log.error("Error: Invalid section")
        }
        
        return cell
    }

}

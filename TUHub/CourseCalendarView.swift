//
//  CourseCalendarView.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import FSCalendar

class CourseCalendarView: UIView {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var courses: [Course]?
    var selectedDate: Date?
    weak var viewController: CoursesViewController?
    
    func setUp(with courses: [Course], from viewController: CoursesViewController?) {
        self.courses = courses
        self.viewController = viewController
        self.calendarView.dataSource = self
    }
    
    func numberOfCourses(for date: Date) -> Int {
        
        guard let selectedDate = selectedDate else {
            return 0
        }
        
        var numberOfCoursesForDate = 0
        if let courses = courses {
            for course in courses {
                if let meetings = course.meetings {
                    for meeting in meetings {
                        if selectedDate > meeting.startDate && selectedDate < meeting.endDate {
                            numberOfCoursesForDate += 1
                        }
                    }
                }
            }
        }
        return numberOfCoursesForDate
        
    }

}

// MARK: - FSCalendarDataSource
extension CourseCalendarView: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return numberOfCourses(for: date)
    }
    
}

// TODO: Complete implementation
// MARK: - UITableViewDataSource
extension CourseCalendarView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedDate = selectedDate {
            return numberOfCourses(for: selectedDate)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        return cell!
    }
    
}

// MARK: - UITableViewDelegate
extension CourseCalendarView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

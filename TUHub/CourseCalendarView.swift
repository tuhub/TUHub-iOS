//
//  CourseCalendarView.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import FSCalendar

fileprivate let courseCalendarCellID = "courseCalendarCell"

protocol CourseCalendarViewDelegate {
    func didSelectDate(_ date: Date)
}

class CourseCalendarView: UIView {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var delegate: CourseCalendarViewDelegate?
    var courses: [Course]?
    var selectedDate: Date!
    fileprivate var selectedDateCourses: [Course]!
    var selectedDateMeetings: [CourseMeeting]! {
        didSet {
            var courses = [Course]()
            for meeting in selectedDateMeetings {
                courses.append(meeting.course)
            }
            selectedDateCourses = courses
        }
    }
    
    
    func setUp(with courses: [Course], delegate: CourseCalendarViewDelegate?) {
        // Init values
        self.courses = courses
        self.delegate = delegate
        
        // Set up calendar view
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.reloadData()
        
        // Get meetings for the current date
        selectedDate = Date()
        selectedDateMeetings = meetings(on: selectedDate)
        
        // Set up table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
    }
    
    func meetings(on date: Date) -> [CourseMeeting]? {
        
        var meetingsForDate = [CourseMeeting]()

        if let courses = courses {
            for course in courses {
                if let meetings = meetings(forCourse: course, on: date) {
                    meetingsForDate.append(contentsOf: meetings)
                }
            }
        }
        
        if meetingsForDate.count == 0 {
            return nil
        }
        
        meetingsForDate.sort { $0.startDate < $1.startDate }
        
        return meetingsForDate
    }

    func meetings(forCourse course: Course, on date: Date) -> [CourseMeeting]? {
        
        guard let meetings = course.meetings else { return nil }
        
        // Get the date's day of the week
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        var meetingsForDate = [CourseMeeting]()
        for meeting in meetings {
            if date > meeting.startDate && date < meeting.endDate && meeting.daysOfWeek.contains(dayOfWeek) {
                meetingsForDate.append(meeting)
            }
        }
        
        if meetingsForDate.count == 0 {
            return nil
        }
        
        return meetingsForDate
    }
    
}

// MARK: - FSCalendarDataSource
extension CourseCalendarView: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return meetings(on: date)?.count ?? 0
    }
    
}

// MARK: - FSCalendarDelegate
extension CourseCalendarView: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        delegate?.didSelectDate(date)
        selectedDateMeetings = meetings(on: date)
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource
extension CourseCalendarView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDateMeetings?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: courseCalendarCellID, for: indexPath)
        if let cell = cell as? CourseCalendarTableViewCell, let selectedDateMeetings = selectedDateMeetings {
            
            let meeting = selectedDateMeetings[indexPath.row]
            cell.setUp(from: meeting)
            if let courseIndex = selectedDateCourses.index(where: {$0.name == meeting.course.name}) {
                cell.separator.backgroundColor = UIColor.allColors[courseIndex % UIColor.allColors.count]
            }
            
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension CourseCalendarView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

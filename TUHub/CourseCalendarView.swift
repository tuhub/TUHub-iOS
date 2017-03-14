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
    weak var viewController: UIViewController?
    
    func setUp(with courses: [Course], from viewController: UIViewController?) {
        self.courses = courses
        self.viewController = viewController
    }

}

// MARK: - FSCalendarDelegate
extension CourseCalendarView: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // TODO: Handle selection
    }
    
}

// TODO: Complete implementation
// MARK: - UITableViewDataSource
extension CourseCalendarView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        // TODO: Handle selection
    }
    
}

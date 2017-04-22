//
//  CourseDetailTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/16/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import EventKit

class CourseDetailTableViewController: UITableViewController {
    
    var dataSource: UITableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        // Retrieve the course's roster if the course a user course
        if let dataSource = dataSource as? CourseTableViewDataSource {
            let course = dataSource.course
            
            title = "\(course.name)-\(course.sectionNumber)"
            
            // Retrieve the roster and display in table view once loaded
            if course.roster == nil {
                course.retrieveRoster() { (_, error) in
                    self.tableView.reloadData()
                }
            }
        } else if let dataSource = dataSource as? CourseSearchResultTableViewDataSource {
            let result = dataSource.result
            title = result.name
        }

        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = dataSource
        
        // Show a done button if being presented modally
        if navigationController?.isBeingPresented ?? false {
            let button = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf))
            button.tintColor = .cherry
            navigationItem.rightBarButtonItem = button
        }
        
    }
    
    func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didPressShare(_ sender: Any) {
        
        let saveBlock: (EKEventStore, [CourseMeeting]) -> Void = { (eventStore, meetings) in
            let calendar = eventStore.defaultCalendarForNewEvents
            let event = EKEvent(eventStore: eventStore)
            for var meeting in meetings {
                event.calendar = calendar
                event.title = meeting.course.name
                event.startDate = meeting.firstMeetingStartDate
                event.endDate = meeting.firstMeetingEndDate
                event.availability = .busy
                event.location = "\(meeting.buildingName) \(meeting.room)"
                
                let daysOfWeek: [EKRecurrenceDayOfWeek] = meeting.daysOfWeek.flatMap {
                    if let weekday = EKWeekday(rawValue: $0 + 1) {
                        return EKRecurrenceDayOfWeek(weekday)
                    }
                    return nil
                }
                let end = EKRecurrenceEnd(end: meeting.lastMeetingEndDate)
                let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly,
                                                      interval: 1,
                                                      daysOfTheWeek: daysOfWeek,
                                                      daysOfTheMonth: nil,
                                                      monthsOfTheYear: nil,
                                                      weeksOfTheYear: nil,
                                                      daysOfTheYear: nil,
                                                      setPositions: nil,
                                                      end: end)
                event.addRecurrenceRule(recurrenceRule)
                
                try? eventStore.save(event, span: .thisEvent)
            }
            try? eventStore.commit()
        }
        
        if let meetings = (dataSource as? CourseTableViewDataSource)?.course.meetings {
            let eventStore = EKEventStore()
            let authStatus = EKEventStore.authorizationStatus(for: .event)
            if authStatus == .notDetermined {
                eventStore.requestAccess(to: .event) { (_, _) in
                    saveBlock(eventStore, meetings)
                }
            } else {
                saveBlock(eventStore, meetings)
            }
            
        }
        
    }
    
}


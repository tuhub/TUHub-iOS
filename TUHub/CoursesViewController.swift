//
//  CoursesViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import FSCalendar

class CoursesViewController: UIViewController {

    fileprivate enum State {
        case calendar, list
    }
    
    @IBOutlet weak var courseCalendarView: CourseCalendarView!
    @IBOutlet weak var courseListView: CourseListView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var dummyTextField: UITextField!
    
    fileprivate var state = State.calendar
    fileprivate var terms: [Term]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load terms/courses
        User.current?.retrieveCourseOverview({ (terms, error) in
            if let error = error {
                debugPrint(error)
            }
            
            if let terms = terms {
                
                self.terms = terms
                self.courseListView.setUp(with: self.terms!, from: self)
                
                for term in terms {
                    
                    debugPrint("-----------------------------")
                    debugPrint(term.name)
                    
                    if let courses = term.courses {
                                                
                        for course in courses {
                            debugPrint(course.name)
                        }
                    }
                }
                self.courseListView.courseTableView.reloadData()
            }
        })

        // Set left bar button's title to the current date
        leftBarButton.title = getFormattedDate(from: Date())
        
        // Set up date picker for the left bar button
        let datePicker = UIDatePicker()
        datePicker.target(forAction: #selector(didChangeDate(_:)), withSender: datePicker)
        dummyTextField.inputView = datePicker
    }
    
    
    override func overrideTraitCollection(forChildViewController childViewController: UIViewController) -> UITraitCollection? {
        if UI_USER_INTERFACE_IDIOM() == .pad &&
            view.bounds.width > view.bounds.height {
            
            let collections = [UITraitCollection(horizontalSizeClass: .regular),
                               UITraitCollection(verticalSizeClass: .compact)]
            return UITraitCollection(traitsFrom: collections)
            
        }
        
        return super.overrideTraitCollection(forChildViewController: childViewController)
    }
    
    func getFormattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }

    @IBAction func didToggleSegmentedControl(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        courseCalendarView.isHidden = selectedIndex == 1
        courseListView.isHidden = selectedIndex == 0
    }
    
    @IBAction func didPressLeftBarButton(_ sender: UIBarButtonItem) {
        if state == .calendar {
            dummyTextField.becomeFirstResponder()
        }
    }
    
    func didChangeDate(_ sender: UIDatePicker) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

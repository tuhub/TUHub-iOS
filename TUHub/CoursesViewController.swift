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

    enum State {
        case calendar, list
    }
    
    @IBOutlet weak var courseCalendarView: CourseCalendarView!
    @IBOutlet weak var courseListView: CourseListView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var dummyTextField: UITextField!
    weak var datePicker: UIDatePicker!
    
    var state = State.calendar
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
                var courses = [Course]()
                
                for term in terms {
                    
                    debugPrint("-----------------------------")
                    debugPrint(term.name)
                    if let c = term.courses {
                        courses.append(contentsOf: c)
                        for course in courses {
                            debugPrint(course.name)
                        }
                    }
                }
                
                self.courseCalendarView.setUp(with: courses, from: self)
                self.courseListView.setUp(with: terms, from: self)
            }
        })

        // Set left bar button's title to the current date
        setLeftButtonTitle(to: Date())
        
        // Set up date picker for the left bar button
        setUpDatePicker()
        
        courseCalendarView.calendarView.delegate = self
    }
    
    func setUpDatePicker() {
        // Set up date picker as input view
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        self.datePicker = datePicker
        dummyTextField.inputView = datePicker
        
        // Set up toolbar with today button and done button as accessory view
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(didPressTodayButton(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDatePickerDoneButton(_:)))
        todayButton.tintColor = UIColor.cherry
        doneButton.tintColor = UIColor.cherry
        toolbar.setItems([todayButton, flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        dummyTextField.inputAccessoryView = toolbar
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
    
    func setLeftButtonTitle(to date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        leftBarButton.title = dateFormatter.string(from: date)
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
    
    func didPressTodayButton(_ sender: UIBarButtonItem) {
        datePicker.setDate(Date(), animated: true)
    }
    
    func didPressDatePickerDoneButton(_ sender: UIBarButtonItem) {
        dummyTextField.resignFirstResponder()
        courseCalendarView.calendarView.select(datePicker.date, scrollToDate: true)
        setLeftButtonTitle(to: datePicker.date)
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

// MARK: - FSCalendarDelegate
extension CoursesViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if state == .calendar {
            setLeftButtonTitle(to: date)
            datePicker.setDate(date, animated: true)
        }
    }
    
}

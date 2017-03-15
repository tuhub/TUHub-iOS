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
    @IBOutlet weak var courseListView: UIView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var dummyTextField: UITextField!
    
    var datePicker: UIDatePicker!
    var termPicker: UIPickerView!
    weak var coursePageVC: CoursePageViewController?
    
    var state = State.calendar
    fileprivate var terms: [Term]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load terms/courses
        User.current?.retrieveCourseOverview({ (terms, error) in
            if let error = error {
                // TODO: Handle error
                debugPrint(error)
            }
            
            if let terms = terms {
                
                self.terms = terms
                var courses = [Course]()
                
                for term in terms {
                    if let c = term.courses {
                        courses.append(contentsOf: c)
                    }
                }
                
                self.courseCalendarView.setUp(with: courses, delegate: self)
                self.coursePageVC?.terms = terms
            }
        })

        // Change calendar scroll direction
        courseCalendarView.calendarView.scrollDirection = .vertical
        
        // Set left bar button's title to the current date
        setLeftButtonTitle(to: Date())
        
        // Set up date picker for the left bar button
        setUpDatePicker()
    }
    
    func setUpDatePicker() {
        
        if datePicker == nil {
            // Set up date picker as input view
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            self.datePicker = datePicker
        }
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
    
    func setUpTermPicker() {
        
        if termPicker == nil {
            // Set up date picker as input view
            let termPicker = UIPickerView()
            termPicker.dataSource = self
            termPicker.delegate = self
            self.termPicker = termPicker
        }
        dummyTextField.inputView = termPicker
        
        // Set up toolbar with today button and done button as accessory view
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressTermPickerDoneButton(_:)))
        doneButton.tintColor = UIColor.cherry
        toolbar.setItems([flexSpace, doneButton], animated: false)
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
        state = sender.selectedSegmentIndex == 0 ? .calendar : .list
        courseCalendarView.isHidden = selectedIndex == 1
        courseListView.isHidden = selectedIndex == 0
        dummyTextField.resignFirstResponder()
        
        if state == .list {
            leftBarButton.title = "Term"
            setUpTermPicker()
        } else {
            setLeftButtonTitle(to: courseCalendarView.selectedDate)
            setUpDatePicker()
        }
    }
    
    @IBAction func didPressLeftBarButton(_ sender: UIBarButtonItem) {
        dummyTextField.becomeFirstResponder()
    }
    
    func didPressTodayButton(_ sender: UIBarButtonItem) {
        datePicker.setDate(Date(), animated: true)
    }
    
    func didPressTermPickerDoneButton(_ sender: UIBarButtonItem) {
        dummyTextField.resignFirstResponder()
        guard let i = coursePageVC?.pages.index(where: { (viewController) -> Bool in
            let courseListVC = viewController as? CourseListViewController
            let row = termPicker.selectedRow(inComponent: 0)
            return courseListVC?.term == terms?[row]
        }) else { return }
        
        coursePageVC?.slideToPage(index: i, completion: nil)
    }
    
    func didPressDatePickerDoneButton(_ sender: UIBarButtonItem) {
        dummyTextField.resignFirstResponder()
        setLeftButtonTitle(to: datePicker.date)
        courseCalendarView.calendarView.select(datePicker.date, scrollToDate: true)
        
        // Due to a bug(?), the calendar delegate isn't informed when we programmatically select date, so we must do it manually
        courseCalendarView.calendar(courseCalendarView.calendarView, didSelect: datePicker.date, at: .notFound)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedCourseListView" {
            if let coursePageVC = segue.destination as? CoursePageViewController {
                coursePageVC.terms = terms
                self.coursePageVC = coursePageVC
            }
        }
    }

}

extension CoursesViewController: CourseCalendarViewDelegate {
    
    func didSelectDate(_ date: Date) {
        if state == .calendar {
            setLeftButtonTitle(to: date)
            datePicker.setDate(date, animated: true)
        }
    }
    
}

extension CoursesViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return terms?.count ?? 0
    }
    
}

extension CoursesViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return terms?[row].name
    }
    
}

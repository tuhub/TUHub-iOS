//
//  CourseViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import FSCalendar

// MARK: - Segue Identifiers
fileprivate let embedSegueID = "embedCourseListView"
fileprivate let showCourseDetailSegueID = "showCourseDetail"
internal let formCourseDetailSegueID = "formCourseDetail"

// MARK: - PerformCourseDetailSegueDelegate
internal protocol PerformCourseDetailSegueDelegate {
    func performSegue(withCourse course: Course)
}

class CourseViewController: UIViewController {

    // MARK: - Types
    /// View states
    enum State {
        case calendar, list
    }
    
    // MARK: - @IBOutlets
    @IBOutlet weak var courseCalendarView: CourseCalendarView!
    @IBOutlet weak var courseListView: UIView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var dummyTextField: UITextField!
    
    // MARK: - Properties
    var datePicker: UIDatePicker!
    var termPicker: UIPickerView!
    weak var coursePageVC: CoursePageViewController?
    let searchController: UISearchController = {
        let resultsController = CourseSearchResultsTableViewController()
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.scopeButtonTitles = ["My Courses", "All Courses"]
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.tintColor = .cherry
        return searchController
    }()
    
    var state = State.calendar
    fileprivate var terms: [Term]?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load terms/courses
        User.current?.retrieveCourses() { (terms, error) in
            if let error = error {
                // TODO: Handle error
                debugPrint(error)
            }
            
            if let terms = terms {
                
                self.terms = terms
                var courses = [Course]()
                
                for term in terms {
                    courses.append(contentsOf: term.courses)
                }
                
                self.courseCalendarView.setUp(with: courses, delegate: self)
                self.coursePageVC?.terms = terms
            }
        }

        // Change calendar scroll direction
        courseCalendarView.calendarView.scrollDirection = .vertical
        courseCalendarView.calendarView.pagingEnabled = UI_USER_INTERFACE_IDIOM() != .pad
        courseCalendarView.performSegueDelegate = self
        
        // Set left bar button's title to the current date
        setLeftButtonTitle(to: Date())
        
        // Set up date picker for the left bar button
        setUpDatePicker()
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Needed to prevent previously selected row from remaining selected
        if let selectedRow = courseCalendarView.tableView.indexPathForSelectedRow {
            courseCalendarView.tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        courseCalendarView.calendarView.layoutSubviews()
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case embedSegueID:
            if let coursePageVC = segue.destination as? CoursePageViewController {
                coursePageVC.performSegueDelegate = self
                coursePageVC.terms = terms
                self.coursePageVC = coursePageVC
            }
        case formCourseDetailSegueID:
            if let courseDetailVC = (segue.destination as? UINavigationController)?.viewControllers.first as? CourseDetailTableViewController,
                let course = sender as? Course {
                
                courseDetailVC.course = course
            }
        case showCourseDetailSegueID:
            if let courseDetailVC = segue.destination as? CourseDetailTableViewController,
                let cell = sender as? UITableViewCell,
                let indexPath = courseCalendarView.tableView.indexPath(for: cell),
                let course = courseCalendarView.selectedDateMeetings?[indexPath.row].course {
                
                courseDetailVC.course = course
            }
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == showCourseDetailSegueID && traitCollection.horizontalSizeClass == .regular {
            return false
        }
        if identifier == formCourseDetailSegueID && traitCollection.horizontalSizeClass == .compact {
            return false
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    // MARK: - Utilities
    func setLeftButtonTitle(to date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        leftBarButton.title = dateFormatter.string(from: date)
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

    // MARK: - @IBActions
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

    @IBAction func didPressSearch(_ sender: UIBarButtonItem) {
        present(searchController, animated: true, completion: nil)
    }
}

// MARK: - CourseCalendarViewDelegate
extension CourseViewController: CourseCalendarViewDelegate {
    
    func didSelectDate(_ date: Date) {
        if state == .calendar {
            setLeftButtonTitle(to: date)
            datePicker.setDate(date, animated: true)
        }
    }
    
}

// MARK: - UIPickerViewDataSource
extension CourseViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return terms?.count ?? 0
    }
    
}

// MARK: - UIPickerViewDelegate
extension CourseViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return terms?[row].name
    }
    
}

// MARK: - PerformCourseDetailSegueDelegate
extension CourseViewController: PerformCourseDetailSegueDelegate {
    
    internal func performSegue(withCourse course: Course) {
        performSegue(withIdentifier: formCourseDetailSegueID, sender: course)
    }

    
}

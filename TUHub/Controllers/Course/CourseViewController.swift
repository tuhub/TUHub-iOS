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
fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    return dateFormatter
}()

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
    @IBOutlet weak var unauthenticatedMessageLabel: UILabel!
    
    lazy var dateDummyTextField: UITextField = {
        let textField = UITextField(frame: CGRect.zero)
        textField.inputView = self.datePicker
        
        // Set up toolbar with today button and done button as accessory view
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(self.didPressTodayButton(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.didPressDatePickerDoneButton(_:)))
        todayButton.tintColor = UIColor.cherry
        doneButton.tintColor = UIColor.cherry
        toolbar.setItems([todayButton, flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        self.view.addSubview(textField)
        return textField
    }()
    lazy var termDummyTextField: UITextField = {
        let textField = UITextField(frame: CGRect.zero)
        textField.inputView = self.termPicker
        
        // Set up toolbar with today button and done button as accessory view
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressTermPickerDoneButton(_:)))
        doneButton.tintColor = UIColor.cherry
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        self.view.addSubview(textField)
        return textField
    }()
    
    lazy var leftBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(self.didPressLeftBarButton))
        self.navigationItem.leftBarButtonItem = button
        return button
    }()
    
    // MARK: - Properties
    lazy var datePicker: UIDatePicker = {
        // Set up date picker as input view
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    lazy var termPicker: UIPickerView = {
        // Set up date picker as input view
        let termPicker = UIPickerView()
        termPicker.dataSource = self
        termPicker.delegate = self
        return termPicker
    }()
    
    // Dispatch once
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Calendar", "List"])
        segmentedControl.addTarget(self, action: #selector(didToggleSegmentedControl(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        self.navigationItem.titleView = segmentedControl
        return segmentedControl
    }()
    
    weak var coursePageVC: CoursePageViewController?
        
    var state = State.calendar
    fileprivate var terms: [Term]?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change calendar scroll direction
        courseCalendarView.calendarView.scrollDirection = .vertical
        courseCalendarView.performSegueDelegate = self
        
        // Load terms/courses
        if let user = User.current {
            
            // Set left bar button's title to the current date
            setLeftButtonTitle(to: Date())
            
            user.retrieveCourses { (terms, error) in
                if let error = error {
                    // TODO: Handle error
                    debugPrint(error)
                }
                
                if let terms = terms {
                    self.terms = terms
                    let courses = terms.flatMap { $0.courses }
                    self.courseCalendarView.setUp(with: courses, delegate: self)
                    self.coursePageVC?.terms = terms
                }
            }
        } else {
            unauthenticatedMessageLabel.isHidden = false
            courseCalendarView.isHidden = true
            courseListView.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add subviews the first time this is called
        if User.current != nil {
            _ = segmentedControl
            _ = dateDummyTextField
            _ = termDummyTextField
            _ = leftBarButton
        }
        
        // Needed to prevent previously selected row from remaining selected
        if let selectedRow = courseCalendarView.tableView.indexPathForSelectedRow {
            courseCalendarView.tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let isPortraitCompact = traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular
        courseCalendarView.calendarView.pagingEnabled = isPortraitCompact
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust calendar view's table view's insets so they appear within the layout guides
        var contentInset = courseCalendarView.tableView.contentInset
        let isPortraitCompact = traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular
        contentInset = UIEdgeInsets(top: isPortraitCompact ? 0 : topLayoutGuide.length, left: contentInset.left, bottom: bottomLayoutGuide.length, right: contentInset.right)
        courseCalendarView.tableView.contentInset = contentInset
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
                
                courseDetailVC.dataSource = CourseTableViewDataSource(course: course)
            }
        case showCourseDetailSegueID:
            if let courseDetailVC = segue.destination as? CourseDetailTableViewController,
                let cell = sender as? UITableViewCell,
                let indexPath = courseCalendarView.tableView.indexPath(for: cell),
                let course = courseCalendarView.selectedDateMeetings?[indexPath.row].course {
                
                courseDetailVC.dataSource = CourseTableViewDataSource(course: course)
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
        leftBarButton.title = dateFormatter.string(from: date)
    }
    
    func didPressTodayButton(_ sender: UIBarButtonItem) {
        datePicker.setDate(Date(), animated: true)
    }
    
    func didPressDatePickerDoneButton(_ sender: UIBarButtonItem) {
        dateDummyTextField.resignFirstResponder()
        setLeftButtonTitle(to: datePicker.date)
        courseCalendarView.calendarView.select(datePicker.date, scrollToDate: true)
        
        // Due to a bug(?), the calendar delegate isn't informed when we programmatically select date, so we must do it manually
        courseCalendarView.calendar(courseCalendarView.calendarView, didSelect: datePicker.date, at: .notFound)
    }
    
    func didPressTermPickerDoneButton(_ sender: UIBarButtonItem) {
        termDummyTextField.resignFirstResponder()
        guard let i = coursePageVC?.pages.index(where: { (viewController) -> Bool in
            let courseListVC = viewController as? CourseListViewController
            let row = termPicker.selectedRow(inComponent: 0)
            return courseListVC?.term == terms?[row]
        }) else { return }
        
        coursePageVC?.slideToPage(index: i, completion: nil)
    }

    func didToggleSegmentedControl(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        state = sender.selectedSegmentIndex == 0 ? .calendar : .list
        courseCalendarView.isHidden = selectedIndex == 1
        courseListView.isHidden = selectedIndex == 0
        dateDummyTextField.resignFirstResponder()
        termDummyTextField.resignFirstResponder()
        
        if state == .list {
            leftBarButton.title = "Term"
        } else {
            setLeftButtonTitle(to: courseCalendarView.selectedDate)
        }
    }
    
    @IBAction func didPressLeftBarButton(_ sender: UIBarButtonItem) {
        if state == .calendar {
            termDummyTextField.resignFirstResponder()
            dateDummyTextField.becomeFirstResponder()
        } else {
            dateDummyTextField.resignFirstResponder()
            termDummyTextField.becomeFirstResponder()
        }
    }

    @IBAction func didPressSearch(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "presentSearchController", sender: nil)
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

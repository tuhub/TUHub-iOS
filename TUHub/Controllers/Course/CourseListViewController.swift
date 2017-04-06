//
//  CourseListViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

// Segue Identifiers
fileprivate let showCourseDetailSegueID = "showCourseDetail"

class CourseListViewController: UIViewController {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var courseTableView: UITableView!
    
    var term: Term?
    var performSegueDelegate: PerformCourseDetailSegueDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting tableView dataSource and delegate
        courseTableView.dataSource = self
        
        // Set term label
        termLabel.text = term?.name
        
        self.title = term?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Needed to prevent previously selected row from remaining selected
        if let selectedRow = courseTableView.indexPathForSelectedRow {
            courseTableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showCourseDetailSegueID {
            if let cell = sender as? UITableViewCell,
                let indexPath = courseTableView.indexPath(for: cell),
                let courseDetailVC = segue.destination as? CourseDetailTableViewController,
                let course = term?.courses[indexPath.row]{
                
                courseDetailVC.dataSource = CourseTableViewDataSource(course: course)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == showCourseDetailSegueID && traitCollection.horizontalSizeClass == .regular {
            
            if let cell = sender as? UITableViewCell,
                let indexPath = courseTableView.indexPath(for: cell),
                let course = term?.courses[indexPath.row] {
                performSegueDelegate?.performSegue(withCourse: course)
            }
            return false
        }
        if identifier == formCourseDetailSegueID && traitCollection.horizontalSizeClass == .compact {
            return false
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }


}

// MARK: - UITableViewDataSource
extension CourseListViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return term?.courses.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseListCell", for: indexPath)
        
        if let course = term?.courses[indexPath.row] {
            // Set course name label
            cell.textLabel?.text = "\(course.name)-\(course.sectionNumber)"
            // Set course description label
            cell.detailTextLabel?.text = course.description ?? course.title
        }
        
        return cell
    }
    
}

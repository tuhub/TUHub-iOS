//
//  CourseListViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

// Segue Identifiers
fileprivate let courseDetailSegueID = "showCourseDetail"

class CourseListViewController: UIViewController {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var courseTableView: UITableView!
    
    var term: Term?
    fileprivate weak var courseDetailVC: CourseListDetailTableViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting tableView dataSource and delegate
        courseTableView.dataSource = self
        courseTableView.delegate = self
        
        // Set term label
        termLabel.text = term?.name
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier! {
            
        case courseDetailSegueID:
            
            guard let cell = sender as? UITableViewCell,
                let indexPath = courseTableView.indexPath(for: cell),
                let courseDetailVC = (segue.destination as? UINavigationController)?.childViewControllers.first as? CourseListDetailTableViewController
                else { break }
            
            courseDetailVC.course = term?.courses?[indexPath.row]
            self.courseDetailVC = courseDetailVC

        default:
            break
        }
    }


}

// MARK: - UITableViewDataSource
extension CourseListViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return term?.courses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseListCell", for: indexPath)
        
        guard let term = term, let courses = term.courses else {
            return cell
        }
        
        // Get all the courses and course description for the term
        let courseName = courses[indexPath.row].name
        let courseDescription = courses[indexPath.row].description
        
        // Set course name label
        cell.textLabel?.text = courseName
        // Set course description label
        cell.detailTextLabel?.text = courseDescription
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension CourseListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

                self.performSegue(withIdentifier: courseDetailSegueID, sender: tableView.cellForRow(at: indexPath))
        
    }
    
}

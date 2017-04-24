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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
}

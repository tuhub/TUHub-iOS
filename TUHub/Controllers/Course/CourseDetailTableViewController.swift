//
//  CourseDetailTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/16/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseDetailTableViewController: UITableViewController {
    
    var dataSource: UITableViewDataSource! {
        didSet {
            if let dataSource = dataSource as? CourseTableViewDataSource {
                let course = dataSource.course
                
                title = "\(course.name)-\(course.sectionNumber)"
                
                // Retrieve the roster and display in table view once loaded
                if course.roster == nil {
                    course.retrieveRoster() { (_, error) in
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false

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

}

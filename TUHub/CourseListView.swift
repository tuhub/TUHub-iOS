//
//  CourseListView.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseListView: UIView {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var terms: [Term]?
    weak var viewController: UIViewController?
    
    
    func setUp(with terms: [Term], from viewController: UIViewController?) {
        self.terms = terms
        debugPrint("listview")
        debugPrint(self.terms?[0].name ?? "Empty")
        //termLabel.text = self.terms?[0].name
        self.viewController = viewController
        
        // Setting tableView delegate
        self.courseTableView.dataSource = self

    }
    
}

// TODO: Implement UITableViewDataSource

// MARK: - UITableViewDataSource
extension CourseListView: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (terms![4].courses?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseListView", for: indexPath)
        
        // Modify to loop through all the term
        let term = terms?[4]
        termLabel.text = term?.name
        
        // Get all the course for the term
        let courseName = term?.courses?[indexPath.row].name
        cell.textLabel?.text = courseName
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension CourseListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Handle selection
    }
    
}

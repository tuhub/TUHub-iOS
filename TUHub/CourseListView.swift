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
        self.viewController = viewController
    }
    
}

// TODO: Implement UITableViewDataSource
// MARK: - UITableViewDataSource
extension CourseListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        return cell!
    }
    
}

// MARK: - UITableViewDelegate
extension CourseListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Handle selection
    }
    
}

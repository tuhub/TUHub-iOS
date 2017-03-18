//
//  CourseSearchResultsTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/17/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

// MARK: - Cell reuse identifier
fileprivate let courseResultCellId = "courseResultCell"

class CourseSearchResultsTableViewController: UITableViewController {

    var results: [Term]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Auto-size cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return results?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?[section].courses.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return results?[section].name ?? nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: courseResultCellId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: courseResultCellId)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        if let course = results?[indexPath.section].courses[indexPath.row] {
            cell.textLabel?.text = course.name
            cell.detailTextLabel?.text = course.title
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let course = results?[indexPath.section].courses[indexPath.row],
            let presentingViewController = presentingViewController,
            let vc = presentingViewController.storyboard?.instantiateViewController(withIdentifier: CourseDetailTableViewController.storyboardID) as? CourseDetailTableViewController
        else { return }
        
        // Set up the CourseDetailTableViewController
        vc.course = course
        
        if traitCollection.horizontalSizeClass == .regular {
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .formSheet
            present(navVC, animated: true, completion: nil)
        } else {
            presentingViewController.show(vc, sender: nil)
        }
    }

}

// MARK: - UISearchResultsUpdating
extension CourseSearchResultsTableViewController: UISearchResultsUpdating {
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        switch searchController.searchBar.selectedScopeButtonIndex {
        
        // My Courses
        case 0:
            if let searchTerm = searchController.searchBar.text {
                User.current?.search(for: searchTerm) { (results) in
                    self.results = results
                    self.tableView.reloadData()
                }
            }
            
        // All Courses
        case 1:
            break
        default:
            log.error("Invalid scope.")
            break
        }
    }

}

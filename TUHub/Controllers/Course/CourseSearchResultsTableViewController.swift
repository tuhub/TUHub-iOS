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

    enum Scope {
        case user, all
        
        init?(_ index: Int) {
            if index == 0 {
                self = .user
            } else if index == 1 {
                self = .all
            } else {
                return nil
            }
        }
    }
    
    var scope: Scope!
    var userResults: [Term]?
    var allResults: [CourseSearchResult]?
    weak var searchController: UISearchController!
    
    // Variables used for pagination of all courses search
    var currentPage = 0
    var allPagesLoaded = false
    var searchText = ""
    
    private let courseResultCell = { () -> UITableViewCell in
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: courseResultCellId)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scope = Scope(searchController.searchBar.selectedScopeButtonIndex)
        searchController.searchBar.delegate = self
        
        clearsSelectionOnViewWillAppear = true
        
        // Auto-size cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if scope == .user {
            return userResults?.count ?? 0
        }
        if scope == .all {
            return allResults != nil ? 1 : 0
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scope == .user {
            return userResults?[section].courses.count ?? 0
        }
        if scope == .all {
            return allResults?.count ?? 0
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if scope == .user {
            return userResults?[section].name ?? nil
        }
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: courseResultCellId) ?? courseResultCell()
        
        if scope == .user {
            if let course = userResults?[indexPath.section].courses[indexPath.row] {
                cell.textLabel?.text = course.name
                cell.detailTextLabel?.text = course.title
            }
        } else if scope == .all {
            if let course = allResults?[indexPath.row] {
                cell.textLabel?.text = course.name
                cell.detailTextLabel?.text = course.title
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let presentingViewController = presentingViewController else { return }
        
        var viewController: UIViewController!
        
        if scope == .user {
            guard let course = userResults?[indexPath.section].courses[indexPath.row],
                let vc = presentingViewController.storyboard?
                    .instantiateViewController(withIdentifier: CourseDetailTableViewController.storyboardID) as? CourseDetailTableViewController
                else { return }
            // Set up the CourseDetailTableViewController
            vc.course = course
            viewController = vc
        } else if scope == .all {
            guard let course = allResults?[indexPath.row] else { return }
            let vc = CourseSearchResultDetailTableViewController()
            vc.result = course
            viewController = vc
        }
        
        if traitCollection.horizontalSizeClass == .regular {
            let navVC = UINavigationController(rootViewController: viewController)
            navVC.modalPresentationStyle = .formSheet
            present(navVC, animated: true, completion: nil)
        } else {
            presentingViewController.show(viewController, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let allResults = allResults, scope == .all, indexPath.row == allResults.count - 1, !allPagesLoaded else { return }
        
        // We've reached the end of the page, load the next one
        currentPage += 1
        CourseSearchResult.search(for: searchText, pageNumber: currentPage) { (results, error) in
            if let results = results {
                if results.isEmpty {
                    self.allPagesLoaded = true
                } else {
                    self.allResults?.append(contentsOf: results)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}

// MARK: - UISearchResultsUpdating
extension CourseSearchResultsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchText: String?) {
        
        // Don't bother searching if no there's no text, clear the results and reload
        guard let searchText = searchText, searchText.characters.count > 0 else {
            userResults = nil
            allResults = nil
            tableView.reloadData()
            return
        }
        self.searchText = searchText
        
        // Reset the page count
        currentPage = 0
        allPagesLoaded = false
        
        switch self.scope! {
            
        // My Courses
        case .user:
            User.current?.search(for: searchText) { (results) in
                self.userResults = results
                self.tableView.reloadData()
            }
            
        // All Courses
        case .all:
            CourseSearchResult.search(for: searchText, pageNumber: 0) { (results, error) in
                if let error = error as? URLError {
                    if error.code == .timedOut {
                        let alertController = UIAlertController(title: "Unable to Load Results", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title: "Dismiss", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.allResults = results
                self.tableView.reloadData()
            }
        }
        
    }
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        scope = Scope(searchController.searchBar.selectedScopeButtonIndex)
        let searchText = searchController.searchBar.text
        if searchText != self.searchText {
            updateSearchResults(for: searchText)
        }
    }

}

// MARK: - UISearchBarDelegate
extension CourseSearchResultsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scope = Scope(selectedScope)
        updateSearchResults(for: searchBar.text)
    }
    
}

//
//  CourseSearchTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/17/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

// MARK: - UITableViewCell reuse identifiers
fileprivate let courseResultCellId = "courseResultCell"

// MARK: - UIStoryboardSegue identifiers
fileprivate let presentDetailID = "presentCourseDetail"
fileprivate let showDetailID = "showCourseDetail"

class CourseSearchTableViewController: UIViewController {
    
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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hairlineHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var scope: Scope!
    var userResults: [Term]?
    var allResults: [CourseSearchResult]?
    
    // Variables used for pagination of all courses search
    var currentPage = 0
    var allPagesLoaded = false
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        if User.current != nil {
            scope = Scope(searchBar.selectedScopeButtonIndex)
        } else {
            scope = .all
            searchBar.scopeButtonTitles = nil
            searchBar.showsScopeBar = false
        }
        
        // Auto-size cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hairlineHeight.constant = CGFloat(1)/UIScreen.main.scale
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        if scope == .user {
            guard let course = userResults?[indexPath.section].courses[indexPath.row]
                else { return }
            // Set up the CourseDetailTableViewController
            let detailVC: CourseDetailTableViewController!
            if let navVC = segue.destination as? UINavigationController {
                detailVC = navVC.childViewControllers.first as! CourseDetailTableViewController
            } else {
                detailVC = segue.destination as! CourseDetailTableViewController
            }
            detailVC.dataSource = CourseTableViewDataSource(course: course)
            
        } else if scope == .all {
            guard let course = allResults?[indexPath.row]
                else { return }
            
            // Set up the CourseDetailTableViewController
            let detailVC: CourseDetailTableViewController!
            if let navVC = segue.destination as? UINavigationController {
                detailVC = navVC.childViewControllers.first as! CourseDetailTableViewController
            } else {
                detailVC = segue.destination as! CourseDetailTableViewController
            }
            detailVC.dataSource = CourseSearchResultTableViewDataSource(result: course)
        }
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == presentDetailID {
            return traitCollection.horizontalSizeClass == .regular
        } else if identifier == showDetailID {
            return traitCollection.horizontalSizeClass == .compact
        }
        return false
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        if let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewBottomConstraint.constant = frame.height
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        tableViewBottomConstraint.constant = 0
    }
    
}

// MARK: - UITableViewDataSource
extension CourseSearchTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if scope == .user {
            return userResults?.count ?? 0
        }
        if scope == .all {
            return allResults != nil ? 1 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scope == .user {
            return userResults?[section].courses.count ?? 0
        }
        if scope == .all {
            return allResults?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if scope == .user {
            return userResults?[section].name ?? nil
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: courseResultCellId, for: indexPath)
        
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
}

extension CourseSearchTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldPerformSegue(withIdentifier: presentDetailID, sender: nil) {
            performSegue(withIdentifier: presentDetailID, sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
extension CourseSearchTableViewController: UISearchBarDelegate {
    
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
        
        // Cancel any pending course search requests
        NetworkManager.shared.cancelAllRequests(for: .courseSearch)
        
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
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.allResults = results
                self.tableView.reloadData()
            }
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != self.searchText {
            updateSearchResults(for: searchText)
        }
        
        tableView.isHidden = searchText.characters.count == 0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scope = Scope(selectedScope)
        updateSearchResults(for: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        NetworkManager.shared.cancelAllRequests(for: .courseSearch)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .transitionFlipFromBottom,
                       animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height) },
                       completion: { _ in
                        self.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
}

//
//  SearchViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

/// Used to display a UISearchController over another view controller without becoming a part of its context
class SearchViewController: UIViewController {
    
    let searchController: UISearchController = {
        let resultsController = CourseSearchResultsTableViewController()
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.scopeButtonTitles = ["My Courses", "All Courses"]
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.tintColor = .cherry
        searchController.hidesNavigationBarDuringPresentation = true
        resultsController.searchController = searchController
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        navigationController?.navigationBar.backgroundColor = .clear
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            present(searchController, animated: true, completion: nil)
        }
    }

}

extension SearchViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        NetworkManager.shared.cancelAllRequests(for: .courseSearch)
        navigationController?.dismiss(animated: false, completion: nil)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

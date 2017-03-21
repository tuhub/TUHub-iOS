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
        searchController.hidesNavigationBarDuringPresentation = false
        resultsController.searchController = searchController
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            present(searchController, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        NetworkManager.cancelAllRequests(for: .courseSearch)
        navigationController?.dismiss(animated: false, completion: nil)
    }
    
}

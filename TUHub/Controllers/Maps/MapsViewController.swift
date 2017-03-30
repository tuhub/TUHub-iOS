//
//  MapsViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class MapsViewController: UIViewController {

    lazy var searchController: UISearchController = {
        let resultsController = MapsSearchResultsTableViewController()
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.hidesBottomBarWhenPushed = true
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchController.searchBar
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

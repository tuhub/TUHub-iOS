//
//  MapsSearchResultsTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class MapsSearchResultsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UISearchResultsUpdating
extension MapsSearchResultsTableViewController: UISearchResultsUpdating {
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        // TODO: Do something
    }

    
}

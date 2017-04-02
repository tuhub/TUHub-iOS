//
//  MarketplaceResponseTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/2/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

fileprivate let contactInformationCellID = "contactInformationCell"
fileprivate let listingResponseCellID = "listingResponseCell"

class MarketplaceResponseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Allow table view to automatically determine cell height based on contents
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case 0:
            return "Contact Information"
        case 1:
            return "Response"

        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: contactInformationCellID, for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: listingResponseCellID, for: indexPath)
        default:
            log.error("Error: Invalid section")
        }
        
        return cell
    }

    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

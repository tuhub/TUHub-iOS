//
//  AddListingTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/1/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

fileprivate let contactInformationCellID = "contactInformationCell"
fileprivate let listingInformationCellID = "listingInformationCell"
fileprivate let addImageCellID = "addImageCell"

class AddListingTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Allow table view to automatically determine cell height based on contents
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case 0:
            return "Contact Information"
        case 1:
            return "Listing Information"
        case 2:
            return "Add Image"

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
                cell = tableView.dequeueReusableCell(withIdentifier: listingInformationCellID, for: indexPath)
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: addImageCellID, for: indexPath)
            default:
                log.error("Error: Invalid section")
              }
            
            return cell
        }
    
    
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

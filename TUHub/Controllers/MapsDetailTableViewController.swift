//
//  MapsDetailTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/11/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI

// UITableViewCell reuse identifier
fileprivate let mapsHeaderCellID = "mapsHeaderCell"
fileprivate let mapsImageCellID = "mapsImageCell"
fileprivate let mapsPhoneNumberCellID = "mapsPhoneNumberCell"


class MapsDetailTableViewController: UITableViewController {
    
    var selectedBusiness: YLPBusiness!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectedBusiness == nil ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: mapsHeaderCellID, for: indexPath)
            (cell as? MapsHeaderTableViewCell)?.setUp(from: selectedBusiness)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: mapsImageCellID, for: indexPath)
            (cell as? MapsImageTableViewCell)?.setUp(from: selectedBusiness)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: mapsPhoneNumberCellID, for: indexPath)
            cell.textLabel?.text = selectedBusiness.phone
        default:
            break
        }
        
        return cell
    }

}

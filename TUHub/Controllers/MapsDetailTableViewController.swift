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
    
    var selectedBusiness: YLPBusiness? {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // One of these lines was causing a crash
//        print(selectedBusiness!.name)
//        print(selectedBusiness!.categories.count)
//        print(selectedBusiness!.categories[0].alias)
//        print(selectedBusiness!.categories[0].name)
//        print(selectedBusiness!.categories[1].name)
//        print(selectedBusiness!.categories[2].name)
//        print(selectedBusiness!.identifier)
//        print(selectedBusiness!.location.address)
//        print(selectedBusiness!.rating)
        
        cell.textLabel?.text = selectedBusiness?.title
        
        return cell
    }

}

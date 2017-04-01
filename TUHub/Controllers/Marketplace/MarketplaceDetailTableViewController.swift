//
//  MarketplaceDetailTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 3/31/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import SafariServices
import TUSafariActivity

fileprivate let listingTitleCellID = "listingTitleCell"
fileprivate let listingImageCellID = "listingImageCell"
fileprivate let listingSellerCellID = "listingSellerCell"
fileprivate let listingPriceCellID = "listingPriceCell"
fileprivate let listingDescriptionCellID = "listingDescriptionCell"



class MarketplaceDetailTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.cellLayoutMarginsFollowReadableWidth = true

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.row {
            
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: listingTitleCellID, for: indexPath)
            cell.textLabel?.text = "iPhone 6s"
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: listingImageCellID, for: indexPath)
            cell.textLabel?.text = "Add Image View Here"
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: listingSellerCellID, for: indexPath)
            cell.textLabel?.text = "Seller"
            cell.detailTextLabel?.text = "Brijesh Nayak"
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: listingPriceCellID, for: indexPath)
            cell.textLabel?.text = "Price"
            cell.detailTextLabel?.text = "$300"
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: listingDescriptionCellID, for: indexPath)
            cell.textLabel?.text = "Description"
            cell.detailTextLabel?.text = "Used iPhone 6s in good condition. Everything functions properly."
        default:
            break
        }
        
        return cell
    }
    
    @IBAction func didPressShare(_ sender: UIBarButtonItem) {
        let url:String? = "https://tuportal4.temple.edu/cp/home/displaylogin"
        if let url = url {
            let openSafariActivity = TUSafariActivity()
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [openSafariActivity])
            let barButtonItem = self.navigationItem.rightBarButtonItem
            let buttonItemView = barButtonItem?.value(forKey: "view") as? UIView
            activityVC.popoverPresentationController?.sourceView = buttonItemView
            present(activityVC, animated: true, completion: nil)
        }
    }
    
}

//
//  MyListingsTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/9/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

class MyListingsTableViewController: UITableViewController {
    
    private var listings: [Listing]?
    private lazy var lock = NSLock()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let group = DispatchGroup()
        
        group.enter()
        Product.retrieve(belongingTo: MarketplaceUser.current!.userId) { (products, error) in
            if let products = products {
                self.insert(listings: products)
                group.leave()
            }
        }
        
        group.enter()
        Job.retrieve(belongingTo: MarketplaceUser.current!.userId) { (jobs, error) in
            if let jobs = jobs {
                self.insert(listings: jobs)
                group.leave()
            }
        }
        
        group.enter()
        Personal.retrieve(belongingTo: MarketplaceUser.current!.userId) { (personals, error) in
            if let personals = personals {
                self.insert(listings: personals)
                group.leave()
            }
        }
        
        group.notify(queue: .main) { 
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return listings == nil ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath)
        
        if let listing = listings?[indexPath.row] {
            cell.textLabel?.text = listing.title
            cell.detailTextLabel?.text = dateFormatter.string(from: listing.datePosted)
        }
        
        return cell
    }
    
    func insert(listings: [Listing]) {
        
        // Enter critical section
        lock.lock()
        
        if self.listings == nil {
            self.listings = listings
        } else {
            self.listings!.append(contentsOf: listings)
        }
        
        self.listings!.sort(by: { $0.datePosted > $1.datePosted })
        
        // Exit critical section
        lock.unlock()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else { return }
        
        if id == "showListingDetail" {
            guard let detailVC = segue.destination as? ListingDetailTableViewController,
                let cell = sender as? UITableViewCell,
                let row = tableView.indexPath(for: cell)?.row,
                let listing = listings?[row]
                else { return }
            
            detailVC.listing = listing
        }
        
    }
    
}

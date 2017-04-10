//
//  ListingsFilterTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/6/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

protocol ListingsFilterDelegate {
    func didSelect(listingKinds: Set<Listing.Kind>)
}

private let listingFilterCellID = "listingFilterCell"

class ListingsFilterTableViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var selectedKinds: Set<Listing.Kind>!
    var delegate: ListingsFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listingFilterCellID, for: indexPath)
        var listingKind: Listing.Kind!
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Products"
            listingKind = .product
        case 1:
            cell.textLabel?.text = "Jobs"
            listingKind = .job
        case 2:
            cell.textLabel?.text = "Personals"
            listingKind = .personal
        default:
            assert(false)
        }

        cell.accessoryType = selectedKinds.contains(listingKind) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var listingKind: Listing.Kind!
        
        switch indexPath.row {
        case 0:
            listingKind = .product
        case 1:
            listingKind = .job
        case 2:
            listingKind = .personal
        default:
            assert(false)
        }
        
        selectedKinds.addOrRemove(listingKind)
        
        // Enable or disable the done button based on whether or not any kinds are selected
        doneButton.isEnabled = selectedKinds.count > 0
        
        // Reload row to show/hide checkmark
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressDone(_ sender: Any) {
        delegate?.didSelect(listingKinds: selectedKinds)
        dismiss(animated: true, completion: nil)
    }

}

extension Set {
    mutating func addOrRemove(_ member: Element) {
        if contains(member) {
            remove(member)
        } else {
            insert(member)
        }
    }
}

//
//  CourseSearchResultDetailTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/19/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

fileprivate let titleCellID = "titleCell"
fileprivate let basicCellID = "basicCell"
fileprivate let rightDetailCellID = "rightDetailCell"

class CourseSearchResultDetailTableViewController: UITableViewController {

    var result: CourseSearchResult?
    
    private let titleCell = { () -> UITableViewCell in
        let cell = UITableViewCell(style: .default, reuseIdentifier: titleCellID)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    private let basicCell = { () -> UITableViewCell in
        let cell = UITableViewCell(style: .default, reuseIdentifier: basicCellID)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    private let rightDetailCell = { () -> UITableViewCell in
        let cell = UITableViewCell(style: .value1, reuseIdentifier: rightDetailCellID)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = result?.name
        tableView.allowsSelection = false
        
        // Remove extra separators
        tableView.tableFooterView = UIView()
        
        // Automatically resize cells based on content height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // Show a done button if being presented modally
        if navigationController?.isBeingPresented ?? false {
            let button = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf))
            button.tintColor = .cherry
            navigationItem.rightBarButtonItem = button
        }
    }
    
    func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = 0
        if let result = result {
            numSections += 2
            if result.levels.count > 0 {
                numSections += 1
            }
            if result.schedule.count > 0 {
                numSections += 1
            }
        }
        return numSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Department"
        case 2:
            return "Levels"
        case 3:
            return "Schedule Types"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return result != nil ? 4 : 0
        case 1:
            return result != nil ? 1 : 0
        case 2:
            return result?.levels.count ?? 0
        case 3:
            return result?.schedule.count ?? 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let result = result else { return UITableViewCell() }
        
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: titleCellID) ?? titleCell()
                cell.textLabel?.text = result.title
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: basicCellID) ?? basicCell()
                cell.textLabel?.text = result.description
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: rightDetailCellID) ?? rightDetailCell()
                cell.textLabel?.text = "Credit Hours"
                cell.detailTextLabel?.text = "\(result.credits)"
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: rightDetailCellID) ?? rightDetailCell()
                cell.textLabel?.text = "Division"
                cell.detailTextLabel?.text = "\(result.division)"
            default:
                break
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: basicCellID) ?? basicCell()
            cell.textLabel?.text = "\(result.college), \(result.department)"
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: basicCellID) ?? basicCell()
            cell.textLabel?.text = result.levels[indexPath.row]
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: basicCellID) ?? basicCell()
            cell.textLabel?.text = result.schedule[indexPath.row]
        default:
            break
        }
        
        return cell
    }
    
}

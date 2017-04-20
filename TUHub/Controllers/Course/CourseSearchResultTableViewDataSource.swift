//
//  CourseSearchResultTableViewDataSource.swift
//  TUHub
//
//  Created by Connor Crawford on 4/5/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseSearchResultTableViewDataSource: NSObject, UITableViewDataSource {
    
    var result: CourseSearchResult
    
    init(result: CourseSearchResult) {
        self.result = result
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = 2
        if result.levels.count > 0 {
            numSections += 1
        }
        if result.schedule.count > 0 {
            numSections += 1
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if result.credits != nil {
                return 4
            }
            return 3
        case 1:
            return 1
        case 2:
            return result.levels.count
        case 3:
            return result.schedule.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withType: .titleCell, for: indexPath)
                cell.textLabel?.text = result.title ?? result.name
            case 1:
                cell = tableView.dequeueReusableCell(withType: .basicCell, for: indexPath)
                cell.textLabel?.text = result.description
            case 2:
                cell = tableView.dequeueReusableCell(withType: .rightDetailCell, for: indexPath)
                if let credits = result.credits {
                    cell.textLabel?.text = "Credit Hours"
                    cell.detailTextLabel?.text = "\(credits)"
                } else {
                    cell = tableView.dequeueReusableCell(withType: .rightDetailCell, for: indexPath)
                    cell.textLabel?.text = "Division"
                    cell.detailTextLabel?.text = "\(result.division)"
                }
            case 3:
                cell = tableView.dequeueReusableCell(withType: .rightDetailCell, for: indexPath)
                cell.textLabel?.text = "Division"
                cell.detailTextLabel?.text = "\(result.division)"
            default:
                break
            }
        case 1:
            cell = tableView.dequeueReusableCell(withType: .basicCell, for: indexPath)
            cell.textLabel?.text = "\(result.college), \(result.department)"
        case 2:
            cell = tableView.dequeueReusableCell(withType: .basicCell, for: indexPath)
            cell.textLabel?.text = result.levels[indexPath.row]
        case 3:
            cell = tableView.dequeueReusableCell(withType: .basicCell, for: indexPath)
            cell.textLabel?.text = result.schedule[indexPath.row]
        default:
            break
        }
        
        return cell
    }
    
}

extension UITableView {
    fileprivate func dequeueReusableCell(withType type: CourseDetailTableViewControllerCellType, for indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: type.rawValue, for: indexPath)
    }
}

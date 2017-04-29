//
//  MoreTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import LocalAuthentication
import SafariServices

class MoreTableViewController: UITableViewController {
    
    fileprivate enum CellType {
        case me, link, toggle, action, button
    }
    
    fileprivate typealias Cell = (id: String, cellType: CellType)
    fileprivate typealias Section = (name: String?, cells: [Cell])
    
    fileprivate var shouldShowTouchID: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && User.current != nil
    }
    
    fileprivate var currentState: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let me: Section? = User.current != nil ? (name: "My TU ID", cells: [(id: "me", cellType: .me)]) : nil
        let links: Section = (name: "Links", cells: [(id: "tumail", cellType: .link),
                                                     (id: "tuportal", cellType: .link),
                                                     (id: "esff", cellType: .link),
                                                     (id: "blackboard", cellType: .link),
                                                     (id: "directory", cellType: .link),
                                                     (id: "flight", cellType: .link),
                                                     (id: "diamond", cellType: .link),
                                                     (id: "health", cellType: .link),
                                                     (id: "safety", cellType: .link),
                                                     (id: "system", cellType: .link),
                                                     (id: "faq", cellType: .link)])
        let dining: Section = (name: "Dining", cells: [(id: "hours", cellType: .link),
                                                       (id: "feedback", cellType: .link),
                                                       (id: "eating", cellType: .link)])
        let security: Section? = shouldShowTouchID ? (name: "Security", cells: [(id: "touch_id", cellType: .toggle)]) : nil
        let courses: Section? = User.current != nil ? (name: "Courses", cells: [(id: "export", cellType: .action)]) : nil
        let account: Section = (name: "Account", cells: [(id: "account", cellType: .button)])
        let sections: [Section] = ([me, links, dining, security, courses, account] as [Section?]).flatMap { $0 }
        
        currentState.append(contentsOf: sections)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentState.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentState[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentState[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let row = currentState[indexPath.section].cells[indexPath.row]
        
        // Initialize cell according to type
        switch row.cellType {
        case .me:
            cell = tableView.dequeueReusableCell(withIdentifier: "meCell", for: indexPath)
            cell.textLabel?.text = User.current?.tuID
        case .link:
            cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath)
            let cell = cell as? LinkTableViewCell
            
            switch row.id {
            case "tumail":
                cell?.textLabel?.text = "TUmail"
                cell?.url = "https://tumail.temple.edu"
            case "tuportal":
                cell?.textLabel?.text = "TUportal"
                cell?.url = "https://tuportal4.temple.edu"
            case "esff":
                cell?.textLabel?.text = "ESFF"
                cell?.url = "http://esff.temple.edu"
            case "blackboard":
                cell?.textLabel?.text = "Blackboard"
                cell?.url = "https://learn.temple.edu"
            case "directory":
                cell?.textLabel?.text = "Cherry & White Directory"
                cell?.url = "https://directory.temple.edu"
            case "flight":
                cell?.textLabel?.text = "Flight"
                cell?.url = "https://tapride-temple.herokuapp.com/ride"
            case "diamond":
                cell?.textLabel?.text = "Diamond Dollars"
                cell?.url = "https://temple.edu/diamonddollars"
            case "health":
                cell?.textLabel?.text = "Student Health Services"
                cell?.url = "https://temple.edu/studenthealth"
            case "safety":
                cell?.textLabel?.text = "Campus Safety"
                cell?.url = "https://prd-mobile.temple.edu/campussafety"
            case "system":
                cell?.textLabel?.text = "System Status"
                cell?.url = "https://computerservices.temple.edu/system-status"
            case "faq":
                cell?.textLabel?.text = "FAQ"
                cell?.url = "https://galaxy.adminsvc.temple.edu/web/m.php?c=823"
            case "hours":
                cell?.textLabel?.text = "Hours"
                cell?.url = "https://apps.temple.edu/tumobile/tudininghours/"
            case "feedback":
                cell?.textLabel?.text = "Feedback"
                cell?.url = "https://apps.temple.edu/TUmobile/TUdiningFeedback/"
            case "eating":
                cell?.textLabel?.text = "What to Eat"
                cell?.url = "https://apps.temple.edu/TUmobile/TUdiningIFeelLikeEating/"
            default:
                log.error("No such row")
            }
        case .toggle:
            cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath)
            let cell = cell as? ToggleTableViewCell
            
            switch row.id {
            case "touch_id":
                cell?.textLabel?.text = "Touch ID"
                cell?.toggle.isOn = UserDefaults.standard.bool(forKey: touchIDKey)
                cell?.toggle.addTarget(self, action: #selector(didToggleTouchID(_:)), for: .valueChanged)
            default:
                log.error("No such row")
            }
        case .action:
            cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            let cell = cell as? ActionTableViewCell
            
            switch row.id {
            case "export":
                cell?.textLabel?.text = "Export to Calendar"
                cell?.title = "Export Courses to Apple Calendar"
                cell?.message = "Pressing \"Export\" will create a new calendar in the Calendar app that contains all of your courses to date. This action is irreversible. Do you wish to proceed?"
                let export = UIAlertAction(title: "Export", style: .destructive) { _ in
                    User.exportCoursesToCalendar(self)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                cell?.actions = [export, cancel]
            default:
                log.error("No such row")
            }
        case .button:
            cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
            let cell = cell as? ButtonTableViewCell
            
            switch row.id {
            case "account":
                cell?.button.setTitle(User.current == nil ? "Sign In" : "Sign Out", for: .normal)
                cell?.button.addTarget(self, action: #selector(unwindToSignIn), for: .primaryActionTriggered)
            default:
                log.error("No such row")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = currentState[indexPath.section].cells[indexPath.row]
        
        switch row.cellType {
        case .link:
            if let urlStr = (tableView.cellForRow(at: indexPath) as? LinkTableViewCell)?.url, let url = URL(string: urlStr) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        case .action:
            guard let cell = tableView.cellForRow(at: indexPath) as? ActionTableViewCell else { break }
            let actionSheet = UIAlertController(title: cell.title, message: cell.message, preferredStyle: .actionSheet)
            if let actions = cell.actions {
                for action in actions {
                    actionSheet.addAction(action)
                }
            }
            
            if let frame = tableView.cellForRow(at: indexPath)?.frame {
                actionSheet.popoverPresentationController?.sourceView = tableView
                actionSheet.popoverPresentationController?.sourceRect = frame
                present(actionSheet, animated: true, completion: nil)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func unwindToSignIn() {
        performSegue(withIdentifier: "unwindToSignIn", sender: nil)
    }
    
    func didToggleTouchID(_ sender: UISwitch) {
        log.info("Touch ID is now \(sender.isOn ? "enabled" : "disabled")")
        UserDefaults.standard.set(sender.isOn, forKey: touchIDKey)
    }

}

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
    
    var templeLinks = ["https://tumail.temple.edu/", "https://tuportal4.temple.edu/cp/home/displaylogin", "https://learn.temple.edu/"]

    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchIDSwitch.isOn = UserDefaults.standard.bool(forKey: touchIDKey)
    }
    
    
    @IBAction func didPressTouchID(_ sender: UISwitch) {
        log.info("Touch ID is now \(touchIDSwitch.isOn ? "enabled" : "disabled")")
        UserDefaults.standard.set(touchIDSwitch.isOn, forKey: touchIDKey)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if let url = URL(string: templeLinks[indexPath.row]) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        }
        
    }

}

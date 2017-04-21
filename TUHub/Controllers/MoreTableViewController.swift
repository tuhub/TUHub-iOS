//
//  MoreTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import LocalAuthentication

class MoreTableViewController: UITableViewController {
    
    var templeLinks = ["https://tumail.temple.edu/", "https://tuportal4.temple.edu/cp/home/displaylogin", "https://learn.temple.edu/"]

    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchIDSwitch.isOn =  UserDefaults.standard.bool(forKey: "switchState")

    }
    
    
    @IBAction func didPressTouchID(_ sender: UISwitch) {
        
        if (touchIDSwitch.isOn == true) {
            debugPrint("Touch ID enabled")
            UserDefaults.standard.set(true, forKey: "state")
            UserDefaults.standard.set(true, forKey: "switchState")
        } else {
            debugPrint("Touch ID disabled")
            UserDefaults.standard.set(false, forKey: "state")
            UserDefaults.standard.set(false, forKey: "switchState")
        }
        
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            url = templeLinks[indexPath.row]
            performSegue(withIdentifier: "showWebView", sender: self)
        }
        
    }

}

//
//  TouchIDViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/21/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import LocalAuthentication

class TouchIDViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.register(defaults: ["state" : true])
        
        

        // Touch ID
        self.authenticateUser()

    }

    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        let reason = "Unlock TUHub"
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                (success, authenticationError) in
                
                if success {
                    print("Login successful")
                } else {
                    self.authenticateUser()
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
}

//
//  TouchIDViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/21/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol TouchIDViewControllerDelegate {
    func didFinishTouchID(success: Bool)
}

class TouchIDViewController: UIViewController {

    var delegate: TouchIDViewControllerDelegate?
    private lazy var visualEffectView: UIVisualEffectView = {
        // Add a blurry background
        let visualEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: visualEffect)
        return visualEffectView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        UserDefaults.standard.register(defaults: ["state" : true])
        
        // Touch ID
        self.authenticateUser()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(visualEffectView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        visualEffectView.frame = view.frame
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        let reason = "Unlock TUHub"
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                (success, authenticationError) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "unwindToSignIn", sender: self)
                }
                self.delegate?.didFinishTouchID(success: success)
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
}

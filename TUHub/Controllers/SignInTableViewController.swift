//
//  SignInTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/19/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

fileprivate let segueIdentifier = "showTabBar"
fileprivate let signInLabelCellID = "signInLabelCell"
fileprivate let usernameFieldCellID = "usernameFieldCell"
fileprivate let passwordFieldCellID = "passwordFieldCell"
fileprivate let skipButtonCellID = "skipButtonCell"
fileprivate let signInButtonCellID = "signInButtonCell"

class SignInTableViewController: UITableViewController {
    
    weak var usernameField: UITextField? {
        didSet{
            if let credential = credential {
                usernameField?.text = credential.username
            }
        }
    }
    weak var passwordField: UITextField?{
        didSet{
            if let credential = credential {
                passwordField?.text = credential.password
            }
        }
    }
    var signInButton: UIButton?
    var credential: Credential?
    
    var isHidden = true

    lazy var invalidCredentialsAlertController: UIAlertController = {
        let alertController = UIAlertController(title: "Unable to Sign In",
                                                message: "Invalid username/password. Please try again.",
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: .default,
                                                handler: nil))
        return alertController
    }()
    
    lazy var mRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66
        
        // Hide the UI since we don't know if it needs to be displayed yet
        hideUI()
        
        // Attempt to sign in silently, show sign-in option if credentials are not stored
        User.signInSilently { (user, error) in
            
            if user != nil {
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            } else {
                // The user needs to sign in, show the UI
                self.showUI()
            }
            
            if let error = error {
                error.displayAlertController(from: self)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineSignInButtonState()
    }
    
    internal func rotated() {
        // Needed to fix bug where label is clipped (despite constraints)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    fileprivate func signIn() {
        if let username = usernameField?.text, let password = passwordField?.text {
            
            User.signIn(username: username, password: password, { (user, error) in
                
                if user != nil {
                    self.performSegue(withIdentifier: segueIdentifier, sender: self)
                } else {
                    self.presentInvalidCredentialsError()
                }
                
            })
            
        } else {
            self.presentInvalidCredentialsError()
        }
    }
    
    private func addRefreshControl() {
        view.addSubview(mRefreshControl)
        view.addConstraint(
            NSLayoutConstraint(item: mRefreshControl,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0))
        view.addConstraint(
            NSLayoutConstraint(item: mRefreshControl,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerY,
                               multiplier: 0.75,
                               constant: 0))
        view.bringSubview(toFront: mRefreshControl)
        mRefreshControl.beginRefreshing()
    }
    
    private func hideUI() {
        addRefreshControl()
        isHidden = true
        tableView.reloadData()
    }
    
    private func showUI() {
        mRefreshControl.endRefreshing()
        mRefreshControl.removeFromSuperview()
        isHidden = false
        tableView.reloadData()
    }
    
    private func presentInvalidCredentialsError() {
        present(invalidCredentialsAlertController, animated: true, completion: nil)
    }
    
    func determineSignInButtonState() {
        if let usernameText = usernameField?.text,
            let passwordText = passwordField?.text,
            usernameText.characters.count > 0 && passwordText.characters.count > 0 {
            signInButton?.isEnabled = true
            signInButton?.backgroundColor = UIColor.cherry
        } else {
            signInButton?.isEnabled = false
            signInButton?.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func unwindToSignInViewController(segue: UIStoryboardSegue) {
        self.credential = User.current!.credential
        showUI()
        User.signOut()
    }
    
    @IBAction func usernameTextFieldDidChange(_ sender: UITextField) {
        credential = nil
        determineSignInButtonState()
    }
    
    @IBAction func passwordTextFieldDidChange(_ sender: UITextField) {
        credential = nil
        determineSignInButtonState()
    }
    
    @IBAction func didPressSkip(_ sender: UIButton) {
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    @IBAction func didPressSignIn(_ sender: UIButton) {
        signIn()
    }
    
    @IBAction func didTapTableView(_ sender: UITapGestureRecognizer) {
        usernameField?.resignFirstResponder()
        passwordField?.resignFirstResponder()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isHidden ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isHidden ? 0 : 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: signInLabelCellID)!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: usernameFieldCellID)!
            usernameField = cell.contentView.viewWithTag(2) as? UITextField
            usernameField?.delegate = self
            usernameField?.layer.borderColor = nil
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: passwordFieldCellID)!
            passwordField = cell.contentView.viewWithTag(3) as? UITextField
            passwordField?.delegate = self
            passwordField?.layer.borderColor = nil
            return cell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: skipButtonCellID)!
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: signInButtonCellID)!
            signInButton = cell.contentView.viewWithTag(4) as? UIButton
            return cell
        default:
            return UITableViewCell()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignInTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField === usernameField {
            passwordField?.becomeFirstResponder()
        } else if textField === passwordField {
            textField.resignFirstResponder()
            signIn()
        }
        
        return true
    }
    
}

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
    
    weak var usernameField: UITextField?
    weak var passwordField: UITextField?
    weak var signInButton: UIButton?

    lazy var invalidCredentialsAlertController: UIAlertController = {
        let alertController = UIAlertController(title: "Unable to Sign In",
                                                message: "Invalid username/password. Please try again.",
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: .default,
                                                handler: nil))
        return alertController
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineSignInButtonState()
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
            // TODO: Alert user that they have not provided both fields
        }
    }
    
    private func hideUI() {
        tableView.isHidden = true
        signInButton?.isHidden = true
    }
    
    private func showUI() {
        tableView.isHidden = false
        signInButton?.isHidden = false
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
        usernameField?.text = ""
        passwordField?.text = ""
        User.signOut()
        showUI()
    }
    
    @IBAction func usernameTextFieldDidChange(_ sender: UITextField) {
        determineSignInButtonState()
    }
    
    @IBAction func passwordTextFieldDidChange(_ sender: UITextField) {
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: signInLabelCellID)!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: usernameFieldCellID)!
            usernameField = cell.contentView.viewWithTag(2) as? UITextField
            usernameField?.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: passwordFieldCellID)!
            passwordField = cell.contentView.viewWithTag(3) as? UITextField
            passwordField?.delegate = self
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

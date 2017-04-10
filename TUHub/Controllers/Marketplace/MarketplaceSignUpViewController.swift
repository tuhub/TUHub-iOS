//
//  MarketplaceSignUpViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/9/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka

class MarketplaceSignUpViewController: FormViewController {

    private var doneButton: UIBarButtonItem!
    
    var userId: String?
    
    var emailIsValid = false
    var fNameIsValid = false
    var lNameIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.tintColor = .cherry
        view.tintColor = .cherry
        
        navigationItem.prompt = "To post to the Marketplace, please sign up"
        navigationItem.title = "Sign Up"
        
        // Add done button
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDone))
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didPressCancel))
        
        (form
            +++ Section("Contact Info")
            <<< EmailRow("emailRow") {
                $0.title = "Email"
                $0.placeholder = "tua12345@temple.edu"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
//                $0.add(rule: RuleMaxLength(maxLength: 100, msg: "Email exceeds max length"))
            }.onChange { (row) in
                self.emailIsValid = row.isValid
                self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            <<< TextRow("fNameRow") {
                $0.title = "First Name"
                $0.placeholder = "John"
                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleMaxLength(maxLength: 40, msg: "First name exceeds max length"))
                $0.validationOptions = .validatesOnChange
            }.onChange { (row) in
                self.fNameIsValid = row.isValid
                self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            <<< TextRow("lNameRow") {
                $0.title = "Last Name"
                $0.placeholder = "Doe"
                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleMaxLength(maxLength: 40, msg: "Last name exceeds max length"))
                $0.validationOptions = .validatesOnChange
            }.onChange { (row) in
                self.lNameIsValid = row.isValid
                self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            <<< PhoneRow("phoneRow") {
                $0.title = "Phone Number"
                $0.placeholder = "Optional"
            }
        )
        // Do any additional setup after loading the view.
    }
    
    func shouldEnableDoneButton() -> Bool {
        return emailIsValid && fNameIsValid && lNameIsValid
    }

    func didPressCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func didPressDone() {
        
        let values = form.values()
        guard let userId = userId,
            let email = values["emailRow"] as? String,
            let firstName = values["fNameRow"] as? String,
            let lastName = values["lNameRow"] as? String
            else {
                log.error("Done button enabled despite invalid form")
                doneButton.isEnabled = false
                return
        }
        let phoneNumber = values["phoneRow"] as? String
        let user = MarketplaceUser(id: userId, email: email, firstName: firstName, lastName: lastName, phone: phoneNumber)
        MarketplaceUser.current = user
        user.post { (error) in
            self.dismiss(animated: true, completion: nil)
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

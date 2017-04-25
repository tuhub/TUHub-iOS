//
//  EditListingViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka

let currencyFormatter: NumberFormatter = {
    let formatter = CurrencyFormatter()
    formatter.locale = .current
    formatter.numberStyle = .currency
    return formatter
}()

protocol EditListingViewControllerDelegate {
    func didUpdate(listing: Listing)
}

class EditListingViewController: FormViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var delegate: EditListingViewControllerDelegate?
    var listing: Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let listing = listing else { return }
        // Set up the form
        (form
            +++ Section()
            <<< SwitchRow("active") {
                $0.title = "Active"
                $0.value = listing.isActive
            }
            
            +++ Section()
            <<< TextRow("titleRow") {
                $0.placeholder = "Title"
                $0.value = listing.title
                
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMaxLength(maxLength: 50))
                $0.add(rule: RuleMinLength(minLength: 1))
                
                $0.validationOptions = .validatesOnChange
                
                }.onChange { _ in self.doneButton.isEnabled = self.shouldEnableDoneButton() }
            <<< DecimalRow("priceRow"){
                $0.useFormatterDuringInput = true
                $0.title = "Price"
                $0.formatter = currencyFormatter
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                if let product = listing as? Product {
                    $0.value = currencyFormatter.number(from: product.price)?.doubleValue
                }
                
                // Hide if type is not product
                $0.hidden = Condition(booleanLiteral: !(listing is Product))
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< TextRow("locRow") {
                $0.placeholder = "Location"
                
                // hide if type is not job or personal
                $0.hidden = Condition(booleanLiteral: listing is Product)
                }.onRowValidationChanged { _,_ in self.doneButton.isEnabled = self.shouldEnableDoneButton() }
            
            <<< IntRow("hoursRow") {
                $0.title = "Weekly Hours"
                
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                if let job = listing as? Job {
                    $0.value = job.hoursPerWeek
                }
                
                
                // Hide if type is not job
                $0.hidden = Condition(booleanLiteral: !(listing is Job))
                }.onRowValidationChanged { _,_ in self.doneButton.isEnabled = self.shouldEnableDoneButton() }
            
            <<< DecimalRow("payRow"){
                $0.useFormatterDuringInput = true
                $0.title = "Hourly Pay"
                $0.placeholder = "Pay"
                $0.value = 0
                
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                // Hide if type is not job
                $0.hidden = Condition(booleanLiteral: !(listing is Job))
                }.onRowValidationChanged { _,_ in self.doneButton.isEnabled = self.shouldEnableDoneButton() }
            
            <<< DateInlineRow("startDateRow") {
                $0.title = "Start Date"
                $0.value = Date()
                
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                // Hide if type is not job
                $0.hidden = Condition(booleanLiteral: !(listing is Job))
                }.onRowValidationChanged { _,_ in self.doneButton.isEnabled = self.shouldEnableDoneButton() }
            
            
            +++ Section("Description")
            <<< TextAreaRow("descRow") {
                $0.title = "Description"
                $0.placeholder = "Enter text here (max 1,000 characters)"
                $0.add(rule: RuleMaxLength(maxLength: 1000))
                $0.value = listing.description
                $0.validationOptions = .validatesOnChange
                }.onRowValidationChanged { _,_ in self.doneButton.isEnabled = self.shouldEnableDoneButton() }
            
        )
    }
    
    func shouldEnableDoneButton() -> Bool {
        return form.validate(includeHidden: false).count == 0
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        // TODO: insert into DB
        let values = form.values(includeHidden: false)
        
        // Get attributes shared by all listings
        guard
            let isActive = values["active"] as? Bool,
            let title = values["titleRow"] as? String
        else { return }
        let desc = values["descRow"] as? String
        
        // Update shared attributes
        listing?.isActive = isActive
        listing?.title = title
        listing?.description = desc
        
        // Update specialized attributes
        if let product = listing as? Product {
            if let price = (values["priceRow"] as? Double) {
                product.price = format(double: price)
            }
        } else if let job = listing as? Job {
            if let hours = values["hoursRow"] as? Int {
                job.hoursPerWeek = hours
            }
            if let pay = values["payRow"] as? Double {
                job.pay = format(double: pay)
            }
            if let date = values["startDateRow"] as? Date {
                job.startDate = date
            }
            job.location = values["locRow"] as? String
        } else if let personal = listing as? Personal {
            personal.location = values["locRow"] as? String
        }
    
        listing?.update { (error) in
            if let _ = error {
                let alert = UIAlertController(title: "Unable to Update Listing", message: "Something went wrong and TUHub was not able to update your listing. Please try again shortly.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            } else {
                self.delegate?.didUpdate(listing: self.listing!)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}

private func format(double: Double) -> String {
    return String(format: "%.02f", locale: Locale.current, arguments: [double])
}

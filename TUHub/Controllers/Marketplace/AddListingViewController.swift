//
//  AddListingViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/7/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

class AddListingViewController: FormViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        // Set up the form
        (form
            +++ Section()
            <<< ActionSheetRow<String>("categoryRow") {
                $0.title = "Category"
                $0.selectorTitle = "Pick a listing category"
                $0.options = [Listing.Kind.product.rawValue,
                              Listing.Kind.job.rawValue,
                              Listing.Kind.personal.rawValue]
                
                $0.value = $0.options.first
                }.onChange{ (_) in
                self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            +++ Section()
            <<< TextRow() {
                $0.placeholder = "Title"
                
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMaxLength(maxLength: 50))
                $0.add(rule: RuleMinLength(minLength: 1))

                $0.validationOptions = .validatesOnChange
                
                }.onChange({ (_) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
                })
            <<< DecimalRow("priceRow"){
                $0.useFormatterDuringInput = true
                $0.title = "Price"
                $0.value = 0
                
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                // Hide if type is not product
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    return (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value != Listing.Kind.product.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< TextRow() {
                $0.placeholder = "Location"
                
                // hide if type is not job or personal
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    let value: String? = (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value
                    return value != Listing.Kind.job.rawValue && value != Listing.Kind.personal.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< IntRow() {
                $0.title = "Weekly Hours"
                $0.value = 0
                
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                // Hide if type is not job
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    let value: String? = (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value
                    return value != Listing.Kind.job.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< DecimalRow(){
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
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    let value: String? = (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value
                    return value != Listing.Kind.job.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< DateInlineRow() {
                $0.title = "Start Date"
                $0.value = Date()
                
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                
                // Hide if type is not job
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    let value: String? = (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value
                    return value != Listing.Kind.job.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            
            +++ Section("Description")
            <<< TextAreaRow() {
                $0.title = "Description"
                $0.placeholder = "Enter text here (max 1,000 characters)"
                $0.add(rule: RuleMaxLength(maxLength: 1000))
                
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            
            +++ Section("Photos")
            <<< ImageRow() {
                $0.title = "Add Photo"
                $0.sourceTypes = .All
                $0.clearAction = .yes(style: .destructive)
            }
        )
    }
    
    func shouldEnableDoneButton() -> Bool {
        for e in form.validate(includeHidden: false) {
            debugPrint(e)
        }
        return form.validate(includeHidden: false).count == 0
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        // TODO: insert into DB
        let values = form.values(includeHidden: false)
        var listing: Listing!
        
        guard let tag = form.rowBy(tag: "categoryRow")?.baseValue as? String else { return }
        switch tag {
        case Listing.Kind.product.rawValue:
            // TODO: Create init with params other than JSON
            // listing = Product()
            break
        case Listing.Kind.job.rawValue:
            // TODO: Create init with params other than JSON
            // listing = job()
            break
        case Listing.Kind.personal.rawValue:
            // TODO: Create init with params other than JSON
            // listing = Personal()
            break
        default:
            assert(false)
        }
        
        for (key, value) in values {
            // Add attrbite to model
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

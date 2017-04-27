//
//  AddListingViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/7/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka
//import ImageRow

protocol AddListingViewControllerDelegate {
    func didAdd(listing: Listing)
}

class AddListingViewController: FormViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var delegate: AddListingViewControllerDelegate?
    
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
            <<< TextRow("titleRow") {
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
            
            <<< TextRow("locRow") {
                $0.placeholder = "Location"
                
                // hide if type is not job or personal
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    let value: String? = (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value
                    return value != Listing.Kind.job.rawValue && value != Listing.Kind.personal.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< IntRow("hoursRow") {
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
                $0.hidden = Condition.function(["categoryRow"]) { (form) -> Bool in
                    let value: String? = (form.rowBy(tag: "categoryRow") as? ActionSheetRow)?.value
                    return value != Listing.Kind.job.rawValue
                }
                }.onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            <<< DateInlineRow("startDateRow") {
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
            <<< TextAreaRow("descRow") {
                $0.title = "Description"
                $0.placeholder = "Enter text here (max 1,000 characters)"
                $0.add(rule: RuleMaxLength(maxLength: 1000))
                
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { (_, row) in
                    self.doneButton.isEnabled = self.shouldEnableDoneButton()
            }
            
            
            +++ Section("Photos")
            <<< ImagesRow("imagesRow") { row in
            }
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
        var listing: Listing?
        
        // Get attributes shared by all listings
        guard
            let tag = values["categoryRow"] as? String,
            let title = values["titleRow"] as? String,
            let user = MarketplaceUser.current
            else { return }
        let desc = values["descRow"] as? String
        let photos = (values["imagesRow"] as? ImageCollection)?.images
        
        switch tag {
        case Listing.Kind.product.rawValue:
            
            // Get attributes for Product
            if let price = values["priceRow"] as? Double {
                listing = Product(title: title, desc: desc, ownerID: user.userId, photosDir: nil, price: price)
            }
        case Listing.Kind.job.rawValue:
            
            if let hours = values["hoursRow"] as? Int, let pay = values["payRow"] as? Double, let date = values["startDateRow"] as? Date {
                
                let loc = values["locRow"] as? String
                
                listing = Job(title: title, desc: desc, ownerID: user.userId, photosDir: nil, location: loc, hours: hours, pay: pay, startDate: date)
            }
        case Listing.Kind.personal.rawValue:
            let loc = values["locRow"] as? String
            listing = Personal(title: title, desc: desc, ownerID: user.userId, photosDir: nil, location: loc)
        default:
            assert(false)
        }
        
        // Post the listing, then get its ID after it's posted to use for the S3 folder name
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        listing?.post { (listing, error) in
            
            guard let listing = listing, error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                // Notify user that their listing wasn't posted
                let alertController = UIAlertController(title: "Unable to Post Listing",
                                                        message: "Something went wrong, and TUHub was not unable to post your listing. Please try again shortly.",
                                                        preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                alertController.addAction(action)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                
                return
            }
            
            
            
            if let dir = listing.photosDirectory, let photos = photos {
                AWS.upload(folder: dir, images: photos) { error in
                    
                    defer { self.delegate?.didAdd(listing: listing)}
                    
                    if error != nil {
                        // Notify user that their images weren't added
                        let alertController = UIAlertController(title: "Unable to Upload Images",
                                                                message: "Your post was added, but TUHub was unable to upload all of your images.",
                                                                preferredStyle: .alert)
                        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        })
                        alertController.addAction(action)
                        
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            } else {
                self.delegate?.didAdd(listing: listing)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        
    }
    
}

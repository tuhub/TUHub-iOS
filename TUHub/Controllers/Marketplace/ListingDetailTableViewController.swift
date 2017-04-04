//
//  MarketplaceDetailTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 3/31/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import SafariServices
import TUSafariActivity
import MessageUI

fileprivate let listingTitleCellID = "listingTitleCell"
fileprivate let listingImageCellID = "listingImageGalleryCell"
fileprivate let listingSellerCellID = "listingSellerCell"
fileprivate let listingPriceCellID = "listingPriceCell"
fileprivate let listingDescriptionCellID = "listingDescriptionCell"

class ListingDetailTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // Email response variables
    var sendEmailTo = ["tue68553@temple.edu"]
    var emailSubject = "TUHub Marketplace Email Test"
    var emailBody = "Hi, \n\nThis is a test for TUHub Marketplace email response."
    
    var newsItem: NewsItem? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.row {
            
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: listingTitleCellID, for: indexPath)
            cell.textLabel?.text = "iPhone 6s"
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: listingImageCellID, for: indexPath)
//            (cell as? ListingImageGalleryTableViewCell)?.setUp(with: newsItem, delegate: self)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: listingSellerCellID, for: indexPath)
            cell.textLabel?.text = "Seller"
            cell.detailTextLabel?.text = "Brijesh Nayak"
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: listingPriceCellID, for: indexPath)
            cell.textLabel?.text = "Price"
            cell.detailTextLabel?.text = "$300"
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: listingDescriptionCellID, for: indexPath)
            let cell = cell as! SubtitleTableViewCell
            cell.titleLabel.text = "Description"
            cell.subtitleLabel.text = "Used iPhone 6s in good condition. Everything functions properly."
        default:
            break
        }
        
        return cell
    }
    
// Handle email response here
    @IBAction func didPressContact(_ sender: Any) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
//        else {
//            self.showSendMailErrorAlert()
//        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.navigationBar.tintColor = UIColor.cherry
        
        // Important to set the "mailComposeDelegate" property
        mailComposerVC.mailComposeDelegate = self
        
        // Send email to
        mailComposerVC.setToRecipients(sendEmailTo)
        // Email subject
        mailComposerVC.setSubject(emailSubject)
        // Email body
        mailComposerVC.setMessageBody(emailBody, isHTML: false)
        
        return mailComposerVC
        
    }
    
    // Gets called when you tap on cancel, send etc.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled mail")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        default:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // It automatically detects if user don't have email account set up, but I don't know if it alert ther user if you cannot send an email.
    func showSendMailErrorAlert() {
        var alertController: UIAlertController?
        
        alertController = UIAlertController(title: "Could Not Send Email.",
                                            message: "Your device could not send e-mail. Please check e-mail configuration and try again.",
                                            preferredStyle: UIAlertControllerStyle.alert)
        alertController?.addAction(UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil))
        
        present(alertController!, animated: true, completion: nil)
    }
    
    @IBAction func didPressShare(_ sender: UIBarButtonItem) {
        let url:String? = "https://tuportal4.temple.edu/cp/home/displaylogin"
        if let url = url {
            let openSafariActivity = TUSafariActivity()
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [openSafariActivity])
            let barButtonItem = self.navigationItem.rightBarButtonItem
            let buttonItemView = barButtonItem?.value(forKey: "view") as? UIView
            activityVC.popoverPresentationController?.sourceView = buttonItemView
            present(activityVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - MarketplaceImageGalleryTableViewCellDelegate
extension ListingDetailTableViewController: MarketplaceImageGalleryTableViewCellDelegate {
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

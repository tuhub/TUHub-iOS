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

class ListingDetailTableViewController: UITableViewController {
    
    var listing: Listing?
    
    // Email response variables
    var sendEmailTo = ["tue68553@temple.edu"]
    var emailSubject:String?
    var emailBody = "Enter your reposnse here...."
    
    // Email Alert
    var alertTitle:String?
    var alertMessage:String?
    
    private lazy var tableViewAttributes: [TableViewAttributes] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        if let listing = listing {
            
            if listing.owner != nil {
                setTableViewAttributes()
            } else {
                tableView.showActivityIndicator()
                listing.retrieveOwner { (user, error) in
                    if error != nil {
                        self.showErrorLabel()
                        return
                    }
                    self.setTableViewAttributes()
                    self.tableView.reloadData()
                    self.tableView.hideActivityIndicator()
                }
            }

        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listing?.owner != nil ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewAttributes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        guard let listing = listing else { return cell }
        let attribute = tableViewAttributes[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: attribute.cellType.rawValue, for: indexPath)
        
        switch attribute.cellType {
        case .titleCell:
            cell.textLabel?.text = attribute.value
        case .imageGalleryCell:
            (cell as! ListingImageGalleryTableViewCell).setUp(with: listing, delegate: self)
        case .rightDetailCell:
            cell.textLabel?.text = attribute.key
            cell.detailTextLabel?.text = attribute.value
        case .subtitleCell:
            let subtitleCell = cell as! SubtitleTableViewCell
            subtitleCell.titleLabel.text = attribute.key
            subtitleCell.subtitleLabel.text = attribute.value
//            cell = subtitleCell
        case .contactCell:
            let contactButtonCell = cell as! ContactDetailViewCell
            emailSubject = attribute.key!
            sendEmailTo = [attribute.value!]

            contactButtonCell.contactButton.tag = indexPath.row
            contactButtonCell.contactButton.addTarget(self, action: #selector(didPressContact), for: .touchUpInside)
            
            // Test
            debugPrint(contactButtonCell.contactButton.tag)
            debugPrint(emailSubject!)
            debugPrint(sendEmailTo[0])
        }
        
        return cell
    }
    
    private func showErrorLabel() {
        
        tableView.tableFooterView?.isHidden = true
        let errorLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: tableView.bounds.size.width,
                                               height: tableView.bounds.size.height))
        errorLabel.text = "Something went wrong"
        errorLabel.textColor = UIColor.darkText
        errorLabel.textAlignment = .center
        tableView.backgroundView = errorLabel
        
    }
    
    private func setTableViewAttributes() {
        if let product = listing as? Product {
            tableViewAttributes = product.tableViewAttributes
        } else if let job = listing as? Job {
            tableViewAttributes = job.tableViewAttributes
        } else if let personal = listing as? Personal {
            tableViewAttributes = personal.tableViewAttributes
        }
    }

    // MARK: Email response
    func didPressContact(){
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
                else {
                    debugPrint("Error: Can not send email.")
                }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.navigationBar.tintColor = UIColor.cherry
        
        // Important to set the "mailComposeDelegate" property
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(sendEmailTo)
        mailComposerVC.setSubject(emailSubject!)
        mailComposerVC.setMessageBody(emailBody, isHTML: false)
        
        return mailComposerVC
        
    }
    

    func showEmailAlert() {
        var alertController: UIAlertController?
        
        alertController = UIAlertController(title: alertTitle,
                                            message: alertMessage,
                                            preferredStyle: UIAlertControllerStyle.alert)
        alertController?.addAction(UIAlertAction(title: "Dismiss",
                                                 style: .default,
                                                 handler: nil))
        
        present(alertController!, animated: true, completion: nil)
    }
   
    // MARK: Share listing?
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

// MARK: Email sent, cancelled, failed error.
extension ListingDetailTableViewController: MFMailComposeViewControllerDelegate {
    
    // Gets called when you tap on cancel, send etc.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
            

        case MFMailComposeResult.sent.rawValue:
            alertTitle = "Email Sent"
            alertMessage = nil
            showEmailAlert()
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            alertTitle = "Email Failed"
            alertMessage = "Something went wrong. Please try again."
            showEmailAlert()
            print("Mail sent")
        default:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MarketplaceImageGalleryTableViewCellDelegate
extension ListingDetailTableViewController: MarketplaceImageGalleryTableViewCellDelegate {
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

// TODO: Add documentation

fileprivate enum CellType: String {
    case titleCell = "titleCell"
    case imageGalleryCell = "imageGalleryCell"
    case rightDetailCell = "rightDetailCell"
    case subtitleCell = "subtitleCell"
    case contactCell = "contactCell"
}


fileprivate typealias TableViewAttributes = (key: String?, value: String?, cellType: CellType)
fileprivate protocol TableViewDisplayable {
    var tableViewAttributes: [TableViewAttributes] { get }
}

extension Product: TableViewDisplayable {
    fileprivate var tableViewAttributes: [TableViewAttributes] {
        if photoPaths != nil {
            return [
                (key: nil, value: title, cellType: .titleCell),
                (key: nil, value: nil, cellType: .imageGalleryCell),
                (key: "Posted On", value: datePosted.date, cellType: .rightDetailCell),
                (key: "Seller", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
                (key: "Price", value: price, cellType: .rightDetailCell),
                (key: "Description", value: description, cellType: .subtitleCell),
                (key: title, value: owner?.email, cellType: .contactCell)
            ]
        } else {
            return [
                (key: nil, value: title , cellType: .titleCell),
                (key: "Posted On", value: datePosted.date, cellType: .rightDetailCell),
                (key: "Seller", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
                (key: "Price", value: price, cellType: .rightDetailCell),
                (key: "Description", value: description, cellType: .subtitleCell),
                (key: title, value: owner?.email, cellType: .contactCell)
            ]
        }
    }
}

extension Job: TableViewDisplayable {
    fileprivate var tableViewAttributes: [TableViewAttributes] {
        
        var attributes: [TableViewAttributes] = [(key: nil, value: title, cellType: .titleCell)]
        
        if photoPaths != nil {
            attributes.append((key: nil, value: nil, cellType: .imageGalleryCell))
        }
        
        attributes.append(contentsOf: [
            (key: "Posted On", value: datePosted.date, cellType: .rightDetailCell),
            (key: "Posted By", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
            (key: "Location", value: location, cellType: .rightDetailCell),
            (key: title, value: owner?.email, cellType: .contactCell)
            ] as [TableViewAttributes])
        
        if let hoursPerWeek = hoursPerWeek {
            attributes.append((key: "Hours per Week", value: "\(hoursPerWeek)", cellType: .rightDetailCell))
        }
        
        attributes.append(contentsOf: [
            (key: "Start Date", value: startDate.date, cellType: .rightDetailCell),
            (key: "Description", value: description, cellType: .subtitleCell)
            ] as [TableViewAttributes])
        
        return attributes
    }
}

extension Personal: TableViewDisplayable {
    fileprivate var tableViewAttributes: [TableViewAttributes] {
        
        var attributes: [TableViewAttributes] = [(key: nil, value: title, cellType: .titleCell)]
        
        if photoPaths != nil {
            attributes.append((key: nil, value: nil, cellType: .imageGalleryCell))
        }
        
        attributes.append(contentsOf: [
            (key: "Posted On", value: datePosted.date, cellType: .rightDetailCell),
            (key: "Posted By", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
            (key: "Location", value: location, cellType: .rightDetailCell),
            (key: "Description", value: description, cellType: .subtitleCell),
            (key: title, value: owner?.email, cellType: .contactCell)
            ] as [TableViewAttributes])
        
        return attributes
    }
}

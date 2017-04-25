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
import SKPhotoBrowser

class ListingDetailTableViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var listing: Listing?
    
    // Email response variables
    var emailRecipient: String?
    
    // Email Alert
    var alertTitle:String?
    var alertMessage:String?
    
    // The current attributes to be displayed in the table view
    fileprivate lazy var tableViewAttributes: [TableViewAttributes] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ImageGalleryTableViewCell", bundle: nil), forCellReuseIdentifier: CellType.imageGalleryCell.rawValue)
        
        // Remove edit button if the listing doesn't belong to the current user
        if listing?.ownerID != MarketplaceUser.current?.userId {
            navigationItem.rightBarButtonItem = nil
        }
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        if let listing = listing {
            
            if let owner = listing.owner {
                setTableViewAttributes()
                emailRecipient = owner.email
            } else {
                tableView.showActivityIndicator()
                self.visualEffectView.isHidden = true
                
                listing.retrieveOwner { (user, error) in
                    if error != nil {
                        self.showErrorLabel()
                        return
                    }
                    if let user = user {
                        self.emailRecipient = user.email
                        
                        if listing.imageURLs == nil {
                            listing.retrievePhotoPaths { (_, _) in
                                self.setTableViewAttributes()
                                self.tableView.reloadData()
                                self.tableView.hideActivityIndicator()
                                self.visualEffectView.isHidden = false
                            }
                        } else {
                            self.setTableViewAttributes()
                            self.tableView.reloadData()
                            self.tableView.hideActivityIndicator()
                            self.visualEffectView.isHidden = false
                        }
                    }
                    
                }
            }

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make table view's separator insets equal on left and right
        var separatorInsets = tableView.separatorInset
        separatorInsets = UIEdgeInsets(top: separatorInsets.top, left: separatorInsets.left, bottom: separatorInsets.bottom, right: separatorInsets.left)
        tableView.separatorInset = separatorInsets
        
        // Make table view's content inset above the directions visual effect view
        var contentInsets = tableView.contentInset
        contentInsets = UIEdgeInsets(top: contentInsets.top, left: contentInsets.left, bottom: contentInsets.bottom + visualEffectView.frame.height, right: contentInsets.right)
        tableView.contentInset = contentInsets
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "showEdit":
            if let editVC = (segue.destination as? UINavigationController)?.childViewControllers.first as? EditListingViewController {
                editVC.delegate = self
                editVC.listing = listing
            }
        default:
            break
        }
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
    @IBAction func didPressContact(){
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
        
        if let emailRecipient = emailRecipient, let listing = listing {
            mailComposerVC.setToRecipients([emailRecipient])
            
            let subject = "Responding to your \(listing.title) listing on TUHub"
            mailComposerVC.setSubject(subject)
            
            let message = "Enter your reposnse here..."
            mailComposerVC.setMessageBody(message, isHTML: false)
        }
        
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
    
    // Maybe add deep linking to support sharing listings if we have time
    //    // MARK: Share listing?
    //    @IBAction func didPressShare(_ sender: UIBarButtonItem) {
    //        let url:String? = "https://tuportal4.temple.edu/cp/home/displaylogin"
    //        if let url = url {
    //            let openSafariActivity = TUSafariActivity()
    //            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [openSafariActivity])
    //            let barButtonItem = self.navigationItem.rightBarButtonItem
    //            let buttonItemView = barButtonItem?.value(forKey: "view") as? UIView
    //            activityVC.popoverPresentationController?.sourceView = buttonItemView
    //            present(activityVC, animated: true, completion: nil)
    //        }
    //    }
    
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

extension ListingDetailTableViewController: UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listing?.owner != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewAttributes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        guard let listing = listing else { return cell }
        let attribute = tableViewAttributes[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: attribute.cellType.rawValue, for: indexPath)
        
        switch attribute.cellType {
        case .titleCell:
            cell.textLabel?.text = attribute.value
        case .imageGalleryCell:
            if let urls = listing.imageURLs?.flatMap({ URL(string: $0) }), let cell = cell as? ImageGalleryTableViewCell {
                cell.setUp(with: urls)
                cell.delegate = self
            }
        case .rightDetailCell:
            cell.textLabel?.text = attribute.key
            cell.detailTextLabel?.text = attribute.value
        case .subtitleCell:
            let subtitleCell = cell as! SubtitleTableViewCell
            subtitleCell.titleLabel.text = attribute.key
            subtitleCell.subtitleTextView.text = attribute.value
        }
        
        return cell
    }
}

// MARK: - MarketplaceImageGalleryTableViewCellDelegate
extension ListingDetailTableViewController: ImageGalleryTableViewCellDelegate {
    func didSelect(imageView: UIImageView, from images: [SKPhoto], at row: Int) {
        if let image = imageView.image {
            let browser = SKPhotoBrowser(originImage: image, photos: images, animatedFromView: imageView)
            browser.initializePageIndex(row)
            present(browser, animated: true, completion: nil)
        }
    }
}

// MARK: - EditListingViewControllerDelegate
extension ListingDetailTableViewController: EditListingViewControllerDelegate {
    func didUpdate(listing: Listing) {
        self.listing = listing
        tableView.reloadData()
    }
}

// TODO: Add documentation

fileprivate enum CellType: String {
    case titleCell = "titleCell"
    case imageGalleryCell = "imageGalleryCell"
    case rightDetailCell = "rightDetailCell"
    case subtitleCell = "subtitleCell"
}

fileprivate typealias TableViewAttributes = (key: String?, value: String?, cellType: CellType)
fileprivate protocol ListingTableViewDisplayable {
    var tableViewAttributes: [TableViewAttributes] { get }
}

extension Product: ListingTableViewDisplayable {
    fileprivate var tableViewAttributes: [TableViewAttributes] {
        var attributes: [TableViewAttributes] = [
            (key: nil, value: title, cellType: .titleCell),
            (key: "Posted On", value: datePosted.datetime, cellType: .rightDetailCell),
            (key: "Seller", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
            (key: "Price", value: price, cellType: .rightDetailCell)
        ]
        
        if imageURLs != nil {
            attributes.insert((key: nil, value: nil, cellType: .imageGalleryCell), at: 1)
        }
        
        if let desc = description, desc.characters.count > 0 {
            attributes.append((key: "Description", value: desc, cellType: .subtitleCell))
        }
        
        return attributes
        
    }
}

extension Job: ListingTableViewDisplayable {
    fileprivate var tableViewAttributes: [TableViewAttributes] {
        
        var attributes: [TableViewAttributes] = [
            (key: nil, value: title, cellType: .titleCell),
            (key: "Posted On", value: datePosted.datetime, cellType: .rightDetailCell),
            (key: "Posted By", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
            (key: "Location", value: location, cellType: .rightDetailCell),
            (key: "Hours per Week", value: "\(hoursPerWeek)", cellType: .rightDetailCell),
            (key: "Start Date", value: startDate.date, cellType: .rightDetailCell)
        ]
        
        if imageURLs != nil {
            attributes.insert((key: nil, value: nil, cellType: .imageGalleryCell), at: 1)
        }
        
        if let desc = description, desc.characters.count > 0 {
            attributes.append((key: "Description", value: desc, cellType: .subtitleCell))
        }
        
        return attributes
    }
}

extension Personal: ListingTableViewDisplayable {
    fileprivate var tableViewAttributes: [TableViewAttributes] {
        
        var attributes: [TableViewAttributes] = [
            (key: nil, value: title, cellType: .titleCell),
            (key: "Posted On", value: datePosted.datetime, cellType: .rightDetailCell),
            (key: "Posted By", value: "\(owner!.firstName) \(owner!.lastName)", cellType: .rightDetailCell),
            (key: "Location", value: location, cellType: .rightDetailCell)
        ]
        
        if imageURLs != nil {
            attributes.insert((key: nil, value: nil, cellType: .imageGalleryCell), at: 1)
        }
        
        if let desc = description, desc.characters.count > 0 {
            attributes.append((key: "Description", value: desc, cellType: .subtitleCell))
        }
        
        return attributes
    }
}

//
//  MapsDetailViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/11/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI
import MapKit
import SKPhotoBrowser

// UITableViewCell reuse identifier
private let headerCellID = "headerCell"
private let imageCellID = "imageCell"
//private let multilineCellID = "multilineCell"
private let phoneCellID = "phoneCell"
private let addressCellID = "addressCell"
private let hoursCellID = "hoursCell"

class MapsDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var yelpClient: YLPClient?
    var location: Location!
    
    fileprivate var showingAllHours = false
    fileprivate var hoursIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide until finished loading
        tableView.isHidden = true
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        tableView.register(UINib(nibName: "ImageGalleryTableViewCell", bundle: nil), forCellReuseIdentifier: imageCellID)
        
        if let business = location as? YLPBusiness {
            activityIndicator.startAnimating()
            yelpClient?.business(withId: business.identifier) { (business, error) in
                defer { DispatchQueue.main.async { self.activityIndicator.stopAnimating() } }
                
                if let error = error {
                    log.error(error)
                    // TODO: Display error message
                    return
                }
                self.location = business
                DispatchQueue.main.async {
                    self.directionsButton.isHidden = false
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            }
        }
        else if let building = location as? Building {
            if building.address == nil {
                activityIndicator.startAnimating()
                building.retrieveAddress { (address, error) in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.tableView.isHidden = false
                        self.directionsButton.isHidden = false
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.tableView.isHidden = false
                self.directionsButton.isHidden = false
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make table view's content inset above the directions visual effect view
        var contentInsets = tableView.contentInset
        contentInsets = UIEdgeInsets(top: contentInsets.top, left: contentInsets.left, bottom: contentInsets.bottom + visualEffectView.frame.height, right: contentInsets.right)
        tableView.contentInset = contentInsets
    }
    
    func makePhoneCall() {
        guard let business = location as? YLPBusiness, let phoneNumber = URL(string: "telprompt://" + business.phone!)
            else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(phoneNumber)
        }
    }
    
    // MARK: Format Phone number
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.characters.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "+1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.characters.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    
    // MARK: Directions Button Pressed
    
    @IBAction func didPressDirections(_ sender: Any) {
        guard let location = location else { return }
        location.openInMaps()
    }
    
}

extension MapsDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return location == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location?.tableViewAttributes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowAttributes = location.tableViewAttributes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowAttributes.identifier, for: indexPath)
        
        switch rowAttributes.key {
        case "header":
            (cell as? MapsHeaderTableViewCell)?.setUp(with: location)
        case "image":
            if let cell = cell as? ImageGalleryTableViewCell {
                cell.setUp(with: location.imageURLs!)
                cell.delegate = self
            }
        case "phone":
            if let business = location as? YLPBusiness, let formattedPhoneNumber = format(phoneNumber: business.phone!) {
                cell.textLabel?.textColor = UIColor.cherry
                cell.textLabel?.text = formattedPhoneNumber
                let tap = UITapGestureRecognizer(target: self, action: #selector(makePhoneCall))
                cell.textLabel?.addGestureRecognizer(tap)
                
                // Set up Call Button
                let callButton = UIButton(type: .custom)
                callButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                callButton.setImage(#imageLiteral(resourceName: "Call"), for: .normal)
                callButton.contentMode = .scaleAspectFit
                callButton.addTarget(self, action:#selector(makePhoneCall), for: .touchUpInside)
                
                cell.accessoryView = callButton
            }
        case "address":
            (cell as? TextViewTableViewCell)?.textView.text = location.address
        case "hours":
            if let business = location as? YLPBusiness, let hours = business.hours {
                (cell as? HoursTableViewCell)?.setUp(hours: hours, isExpanded: showingAllHours, inset: tableView.separatorInset)
            }
            hoursIndexPath = indexPath
        default:
            assert(false)
        }
        
        return cell
    }
    
    @IBAction func reloadHoursCell() {
        showingAllHours = !showingAllHours
        if let hoursIndexPath = hoursIndexPath {
            self.tableView.reloadRows(at: [hoursIndexPath], with: .fade)
        }
    }
    
}

extension String.CharacterView {
    
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

extension Building: TableViewDisplayable {
    var tableViewAttributes: [TableViewAttributes] {
        var attr: [TableViewAttributes] = [(key: "header", identifier: headerCellID)]
        
        if imageURLs != nil {
            attr.append((key: "image", identifier: imageCellID))
        }
        
        if address != nil {
            attr.append((key: "address", identifier: addressCellID))
        }
        
        return attr
    }
}

extension YLPBusiness: TableViewDisplayable {
    
    var tableViewAttributes: [TableViewAttributes] {
        var attr: [TableViewAttributes] = [(key: "header", identifier: headerCellID)]
        
        if imageURLs != nil {
            attr.append((key: "image", identifier: imageCellID))
        }
        
        if phone != nil {
            attr.append((key: "phone", identifier: phoneCellID))
        }
        
        attr.append((key: "address", identifier: addressCellID))
        
        if hours != nil {
            attr.append((key: "hours", identifier: hoursCellID))
        }
        return attr
    }
    
}

extension MapsDetailViewController: ImageGalleryTableViewCellDelegate {
    func didSelect(imageView: UIImageView, from images: [SKPhoto], at row: Int) {
        if let image = imageView.image {
            let browser = SKPhotoBrowser(originImage: image, photos: images, animatedFromView: imageView)
            browser.initializePageIndex(row)
            present(browser, animated: true, completion: nil)
        }
    }
}

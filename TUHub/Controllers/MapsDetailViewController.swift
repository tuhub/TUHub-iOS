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

// UITableViewCell reuse identifier
private let headerCellID = "headerCell"
private let imageCellID = "imageCell"
private let multilineCellID = "multilineCell"
private let hoursCellID = "hoursCell"

class MapsDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var yelpClient: YLPClient!
    var businessID: String!
    var business: YLPBusiness?
    
    fileprivate var showingAllHours = false
    fileprivate var hoursIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        yelpClient.business(withId: businessID) { (business, error) in
            defer { DispatchQueue.main.async { self.activityIndicator.stopAnimating() } }
            
            if let error = error {
                log.error(error)
                // TODO: Display error message
                return
            }
            self.business = business
            DispatchQueue.main.async {
                self.directionsButton.isHidden = false
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var inset = tableView.separatorInset
        inset = UIEdgeInsets(top: inset.top, left: inset.left, bottom: inset.bottom, right: inset.left)
        tableView.separatorInset = inset
    }
    
    func makePhoneCall() {
        guard let phoneNumber = URL(string: "telprompt://" + (business?.phone)!)
            else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(phoneNumber)
        }
        debugPrint("Call")
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
        
        guard let business = business,
            let latitude = business.location.coordinate?.latitude,
            let longitude = business.location.coordinate?.longitude
            else { return }
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = business.name
        mapItem.phoneNumber = business.phone
        mapItem.openInMaps(launchOptions: options)
        
    }
    
}

extension MapsDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if business != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 3
        
        if business?.imageURL != nil {
            numRows += 1
        }
        if business?.hours != nil {
            numRows += 1
        }
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let business = self.business!
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: headerCellID, for: indexPath)
                (cell as? MapsHeaderTableViewCell)?.setUp(from: business)
            case 1:
                if business.imageURL != nil {
                    cell = tableView.dequeueReusableCell(withIdentifier: imageCellID, for: indexPath)
                    (cell as? MapsImageTableViewCell)?.setUp(from: business)
                } else {
                    fallthrough
                }
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: multilineCellID, for: indexPath)
                cell.textLabel?.text = ""
                for (i, line) in business.location.address.enumerated() {
                    cell.textLabel?.text! += "\(line)"
                    if i == business.location.address.count - 1 {
                        cell.textLabel?.text! += "\n"
                    } else {
                        cell.textLabel?.text! += ", "
                    }
                }
                cell.textLabel?.text! += "\(business.location.city), \(business.location.stateCode)\n"
                cell.textLabel?.text! += "\(business.location.postalCode)\n"
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: multilineCellID, for: indexPath)
                
                if let phone = business.phone, let formattedPhoneNumber = format(phoneNumber: phone) {
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
                    
                    cell.accessoryView = callButton as UIView
                    
                }
            case 4:
                cell = tableView.dequeueReusableCell(withIdentifier: hoursCellID, for: indexPath)
                if let hours = business.hours {
                    (cell as? HoursTableViewCell)?.setUp(with: hours, isExpanded: showingAllHours)
                }
                hoursIndexPath = indexPath
            default:
                break
            }
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



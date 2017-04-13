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
fileprivate let mapsHeaderCellID = "mapsHeaderCell"
fileprivate let mapsImageCellID = "mapsImageCell"
fileprivate let mapsPhoneNumberCellID = "mapsPhoneNumberCell"


class MapsDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var selectedBusiness: YLPBusiness!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    // MARK: Directions Button Pressed
    
    @IBAction func didPressDirections(_ sender: Any) {
        
        let latitude = selectedBusiness.location.coordinate!.latitude
        let longitude = selectedBusiness.location.coordinate!.longitude
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = selectedBusiness.name
        mapItem.phoneNumber = selectedBusiness.phone
        mapItem.openInMaps(launchOptions: options)
        
    }
    
}

extension MapsDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedBusiness == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: mapsHeaderCellID, for: indexPath)
            (cell as? MapsHeaderTableViewCell)?.setUp(from: selectedBusiness)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: mapsImageCellID, for: indexPath)
            (cell as? MapsImageTableViewCell)?.setUp(from: selectedBusiness)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: mapsPhoneNumberCellID, for: indexPath)
            
            if let phone = selectedBusiness.phone, let formattedPhoneNumber = format(phoneNumber: phone) {
                cell.textLabel?.text = formattedPhoneNumber
            }
            else {
                cell.textLabel?.text = nil
            }
            
        default:
            break
        }
        
        return cell
    }
    // MARK: Formate Phone number
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
            leadingOne = "1 "
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



//
//  MapsBuildingDetailViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/15/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import MapKit

// UITableViewCell reuse identifier
private let headerCellID = "headerCell"
private let imageCellID = "imageCell"
private let multilineCellID = "multilineCell"

class MapsBuildingDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var building: Building?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var inset = tableView.separatorInset
        inset = UIEdgeInsets(top: inset.top, left: inset.left, bottom: inset.bottom, right: inset.left)
        tableView.separatorInset = inset
    }
    @IBAction func didPressDirections(_ sender: Any) {
        guard let building = building,
            let latitude = self.building?.coordinate.latitude,
            let longitude = self.building?.coordinate.longitude
            else { return }
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = building.name
        mapItem.openInMaps(launchOptions: options)
    }
    
}

extension MapsBuildingDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if building != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 2
        
        if building?.imageURL != nil {
            numRows += 1
        }
        if building?.address != nil {
            numRows += 1
        }
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let building = self.building!
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: headerCellID, for: indexPath)
                cell.textLabel?.text = building.name
            case 1:
                if building.imageURL != nil {
                    cell = tableView.dequeueReusableCell(withIdentifier: imageCellID, for: indexPath)
                    (cell as? MapsBuildingImageTableViewCell)?.setUp(from: building)
                } else {
                    fallthrough
                }
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: multilineCellID, for: indexPath)
                cell.textLabel?.text = building.address
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: multilineCellID, for: indexPath)
                cell.textLabel?.text = building.campusID
            default:
                break
            }
        }
        return cell
        
    }
}

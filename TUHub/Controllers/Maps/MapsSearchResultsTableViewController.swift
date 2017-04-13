//
//  MapsSearchResultsTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI
import MapKit

class MapsSearchResultsTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MapsSearchResultsTableViewControllerDelegate?
    var yelpClient: YLPClient?
    var campuses: [Campus]?
    var region: MKCoordinateRegion?
    var insets: UIEdgeInsets?
    
    lazy var buildingResults: [Building] = []
    lazy var businessResults: [YLPBusiness] = []
    var yelpQuery: YLPQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        if let insets = insets {
            tableView.contentInset = insets
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension MapsSearchResultsTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return buildingResults.count
        case 1:
            return businessResults.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return buildingResults.count > 0 ? "Buildings" : nil
        case 1:
            return businessResults.count > 0 ? "Businesses" : nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = indexPath.section == 0 ? "buildingCell" : "businessCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        switch indexPath.section {
        case 0:
            let building = buildingResults[indexPath.row]
            cell.textLabel?.text = building.name
            if let i = campuses?.index(where: { $0.id == building.campusID }) {
                cell.detailTextLabel?.text = campuses?[i].name
            }
        case 1:
            if let cell = cell as? BusinessTableViewCell {
                let business = businessResults[indexPath.row]
                cell.titleLabel.text = business.name
                cell.starView.rating = business.rating
                cell.detailLabel.text = ""
                
                for (i, category) in business.categories.enumerated() {
                    var text = cell.detailLabel.text!
                    text += category.name
                    if i < business.categories.count - 1 {
                        text += ", "
                    }
                    cell.detailLabel.text = text
                }
            }
        default:
            break
        }
        
        return cell
    }
    
}

extension MapsSearchResultsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == businessResults.count - 1, let query = yelpQuery {
            // Load next page of Yelp results
            query.offset = UInt(indexPath.row)
            yelpClient?.search(with: query) { (search, error) in
                if let error = error {
                    log.error(error)
                    return
                }
                if let businesses = search?.businesses {
                    self.businessResults.append(contentsOf: businesses)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let building = buildingResults[indexPath.row]
            delegate?.didSelect(building: building)
        case 1:
            let business = businessResults[indexPath.row]
            delegate?.didSelect(business: business)
        default:
            break
        }
    }
}

// MARK: - UISearchResultsUpdating
extension MapsSearchResultsTableViewController: UISearchResultsUpdating {
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        if let campuses = campuses {
            for campus in campuses {
                if let buildings = campus.buildings {
                    DispatchQueue.global(qos: .userInteractive).async {
                        var results: [(building: Building, index: String.Index)] = []
                        
                        for building in buildings {
                            if let minIndex = building.name.lowercased().index(of: searchText) {
                                results.append((building: building, index: minIndex))
                            }
                        }
                        
                        results.sort {
                            if $0.index == $1.index {
                                return $0.building.name < $1.building.name
                            }
                            return $0.index < $1.index
                        }
                        
                        DispatchQueue.main.async {
                            self.buildingResults = results.map { $0.building }
                            self.tableView.reloadData()
                        }
                    }
                }

            }
        }
        
        if let region = region {
            let coordinate = YLPCoordinate(latitude: region.center.latitude, longitude: region.center.longitude)
            let query = YLPQuery(coordinate: coordinate)
            query.radiusFilter = Double(Int(region.radius))
            query.limit = 20
            query.sort = .bestMatched
            query.term = searchText
            self.yelpQuery = query
            
            yelpClient?.search(with: query) { (search, error) in
                self.businessResults.removeAll()
                
                if let error = error {
                    log.error(error)
                    return
                }
                
                DispatchQueue.main.async {
                    if let businesses = search?.businesses {
                        self.businessResults = businesses
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    
}

protocol MapsSearchResultsTableViewControllerDelegate {
    func didSelect(business: YLPBusiness)
    func didSelect(building: Building)
}

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
    
    lazy var buildingResults: [Building] = []
    lazy var businessResults: [YLPBusiness] = []
    lazy var buildings: [Building] = []
    lazy var businesses: [YLPBusiness] = []
    
    var yelpQuery: YLPQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bottom = presentingViewController?.bottomLayoutGuide.length ?? 0
        let top = presentingViewController?.topLayoutGuide.length ?? 0
        self.tableView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }

}

extension MapsSearchResultsTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return buildings.count
        case 1:
            return businesses.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return buildings.count > 0 ? "Buildings" : nil
        case 1:
            return businesses.count > 0 ? "Businesses" : nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = indexPath.section == 0 ? "buildingCell" : "businessCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        switch indexPath.section {
        case 0:
            let building = buildings[indexPath.row]
            cell.textLabel?.text = building.name
            if let i = campuses?.index(where: { $0.id == building.campusID }) {
                cell.detailTextLabel?.text = campuses?[i].name
            }
        case 1:
            if let cell = cell as? BusinessTableViewCell {
                let business = businesses[indexPath.row]
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
        if indexPath.section == 1, indexPath.row == businesses.count - 1, let query = yelpQuery {
            // Load next page of Yelp results
            query.offset = UInt(indexPath.row)
            yelpClient?.search(with: query) { (search, error) in
                if let error = error {
                    log.error(error)
                    return
                }
                if let businesses = search?.businesses {
                    if businesses.count > 0 {
                        DispatchQueue.main.async {
                            self.businesses.append(contentsOf: businesses)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let building = buildings[indexPath.row]
            delegate?.didSelect(location: building)
        case 1:
            let business = businesses[indexPath.row]
            delegate?.didSelect(location: business)
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
        
        let group = DispatchGroup()
        
        if let campuses = campuses {
            for campus in campuses {
                if let buildings = campus.buildings {
                    
                    // Add to dispatch group
                    group.enter()
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
                        
                        self.buildingResults = results.map { $0.building }
                        group.leave()
                    }
                }

            }
        }
        
        if let region = region {
            let coordinate = YLPCoordinate(latitude: region.center.latitude, longitude: region.center.longitude)
            let query = YLPQuery(coordinate: coordinate)
            query.radiusFilter = Double(Int(region.radius))
            query.limit = 3
            query.sort = .bestMatched
            query.term = searchText
            self.yelpQuery = query
            
            // Add to dispatch group
            group.enter()
            yelpClient?.search(with: query) { (search, error) in
                self.businessResults.removeAll()
                
                if let error = error {
                    log.error(error)
                    return
                }
                
                if let businesses = search?.businesses {
                    self.businessResults = businesses
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { 
            self.buildings = self.buildingResults
            self.businesses = self.businessResults
            self.tableView.reloadData()
        }
        
    }

    
}

protocol MapsSearchResultsTableViewControllerDelegate {
    func didSelect(location: Location)
}

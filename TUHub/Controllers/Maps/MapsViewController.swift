//
//  MapsViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import ISHHoverBar
import YelpAPI

// Segue Identifiers
private let mapsDetailSegueID = "showMapsDetail"

private let defaultCampusKey = "defaultCampus"

class MapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    lazy var searchController: UISearchController = {
        let resultsController = self.storyboard!.instantiateViewController(withIdentifier: "MapsSearchResultsVC") as! MapsSearchResultsTableViewController
        
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.hidesBottomBarWhenPushed = true
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    var locationButton: MKUserTrackingBarButtonItem!
    let locationManager = CLLocationManager()
    var yelpClient: YLPClient?
    
    lazy var businesses: [YLPBusiness] = []
    var selectedBusinessID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Put search bar in navigation bar
        navigationItem.titleView = searchController.searchBar
        
        // Set up toolbar
        let hoverBar = ISHHoverBar(frame: CGRect(x: 0, y: 0, width: 44, height: 88))
        let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "InfoIcon"), style: .plain, target: nil, action: nil) // TODO: Add action for info button
        locationButton = MKUserTrackingBarButtonItem(mapView: mapView)
        hoverBar.items = [infoButton, locationButton]
        hoverBar.orientation = .vertical
        hoverBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hoverBar)
        
        // Add constraints
        let trailingConstraint = NSLayoutConstraint(item: hoverBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: hoverBar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 8)
        NSLayoutConstraint.activate([trailingConstraint, topConstraint])
        
        // Map view set up
        mapView.delegate = self
        
        // Location manager set up
//        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Retrieve campuses and their buildings
        Campus.retrieveAll { (campuses, error) in
            guard error == nil, let campuses = campuses else {
                let alertController = UIAlertController(title: "Unable to Retrieve Campus Information",
                                                        message: "TUHub was unable to retrieve campus and building information from Temple's servers. Please try again shortly.",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss",
                                                        style: .default,
                                                        handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let defaults = UserDefaults.standard
            if let defaultCampusID = defaults.string(forKey: defaultCampusKey) {
                
                // Find the campus object corresponding to the default campus ID
                if let i = campuses.index(where: { $0.id == defaultCampusID }) {
                    let campus = campuses[i]
                    
                    // Set campus as mapView's region
                    DispatchQueue.main.async {
                        self.mapView.setRegion(campus.region, animated: false)
                        self.loadBusiness(in: campus.region)
                    }
                }
                // The default campus has been removed, ask to select a new one
                else {
                    self.showDefaultCampusSelection(campuses)
                }
            }
            // No default campus selected, prompt to select one
            else {
                self.showDefaultCampusSelection(campuses)
            }
            
            if let resultsController = self.searchController.searchResultsController as? MapsSearchResultsTableViewController {
                resultsController.campuses = campuses
            }
            
        }

        
        // Set up Yelp Client
        YLPClient.authorize(withAppId: YLPClient.id, secret: YLPClient.secret) { (client, error) in
            if let error = error {
                log.error(error)
                return
            }
            self.yelpClient = client
            
            if let resultsController = self.searchController.searchResultsController as? MapsSearchResultsTableViewController {
                resultsController.yelpClient = client
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        let resultsController = searchController.searchResultsController as? MapsSearchResultsTableViewController
        resultsController?.insets = insets
        resultsController?.delegate = self

    }
    
    func showDefaultCampusSelection(_ campuses: [Campus]) {
        let actionSheet = UIAlertController(title: "Select Your Default Campus", message: "Select the campus that you would like to be displayed when you first open the app.", preferredStyle: .actionSheet)
        
        for campus in campuses {
            let action = UIAlertAction(title: campus.name, style: .default) { (action) in
                
                // Save selection to user defaults
                let defaults = UserDefaults.standard
                defaults.set(campus.id, forKey: defaultCampusKey)
                
                // Show selection on map
                DispatchQueue.main.async {
                    self.mapView.setRegion(campus.region, animated: false)
                    self.loadBusiness(in: campus.region)
                }
                
            }
            actionSheet.addAction(action)
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case mapsDetailSegueID:
            guard let selectedBusinessID = self.selectedBusinessID,
                let yelpClient = self.yelpClient,
                let mapsDetailVC = segue.destination as? MapsDetailViewController
                else { break }
                mapsDetailVC.businessID = selectedBusinessID
                mapsDetailVC.yelpClient = yelpClient
        default:
            break
        }
    }
 

}

// MARK: - MKMapViewDelegate
extension MapsViewController: MKMapViewDelegate {
    
    func loadBusiness(in region: MKCoordinateRegion) {
        let center = region.center
        let coordinate = YLPCoordinate(latitude: center.latitude, longitude: center.longitude)
        
        // Set up query
        let query = YLPQuery(coordinate: coordinate)
        query.radiusFilter = Double(Int(region.radius)) // radiusFilter is a double, but the API takes an int? Nice job Yelp
        query.sort = .distance
        query.limit = 20
        query.term = "food"
        
        yelpClient?.search(with: query) { (search, error) in
            if let error = error {
                log.error(error)
                return
            }
            
            if let businesses = search?.businesses {
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(businesses)
                    self.businesses.append(contentsOf: businesses)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Notify the resultsController of the region change
        if let resultsController = searchController.searchResultsController as? MapsSearchResultsTableViewController {
            resultsController.region = mapView.region
        }
        
        // Remove old annotations
        mapView.removeAnnotations(self.businesses)
        self.businesses.removeAll()
        
        // Load new businesses in this region
        loadBusiness(in: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.selectedBusinessID = (view.annotation as? YLPBusiness)?.identifier
        self.performSegue(withIdentifier: "showMapsDetail", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if annotation is MKUserLocation {
            //return nil so map view draws dot for standard user location instead of pin
            return nil
        }
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = false
            pinView?.pinTintColor = UIColor.cherry
            pinView?.isDraggable = false
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
}

extension MapsViewController: MapsSearchResultsTableViewControllerDelegate {
    func didSelect(building: Building) {
        searchController.isActive = false
        mapView.addAnnotation(building)
        mapView.setCenter(building.coordinate, animated: true)
        mapView.selectAnnotation(building, animated: true)
    }
    
    func didSelect(business: YLPBusiness) {
        searchController.isActive = false
        mapView.addAnnotation(business)
        mapView.setCenter(business.coordinate, animated: true)
        mapView.selectAnnotation(business, animated: true)
    }
}

extension Building: MKAnnotation {
    var title: String? {
        return self.name
    }
}

extension YLPBusiness: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let ylpCoord = self.location.coordinate
        let lat: Double = ylpCoord?.latitude ?? 0
        let long: Double = ylpCoord?.longitude ?? 0
        
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    public var title: String? {
        return self.name
    }
}

extension MKCoordinateRegion {
    
    /// Radius in meters
    var radius: Double {
        let loc1 = CLLocation(latitude: center.latitude - (span.latitudeDelta / 2), longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + (span.latitudeDelta / 2), longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - (span.longitudeDelta / 2))
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + (span.longitudeDelta / 2))
        
        return max(loc1.distance(from: loc2), loc3.distance(from: loc4))
    }
    
}

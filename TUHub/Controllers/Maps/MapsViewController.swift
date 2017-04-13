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
fileprivate let mapsDetailSegueID = "showMapsDetail"

let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)

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
    
    lazy var centerMapFirstTime: Void = {
        // Retrieve campuses and their buildings
        Campus.retrieveAll { (campuses, error) in
            guard error == nil else {
                let alertController = UIAlertController(title: "Unable to Retrieve Campus Information",
                                                        message: "TUHub was unable to retrieve campus and building information from Temple's servers. Please try again shortly.",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss",
                                                        style: .default,
                                                        handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if let campuses = campuses, let nearest = self.nearest(of: campuses) {
                if let resultsController = self.searchController.searchResultsController as? MapsSearchResultsTableViewController {
                    resultsController.campuses = campuses
                }
                self.mapView.setRegion(nearest.region, animated: false)
                self.loadBusiness(in: nearest.region)
            }
        }
    }()
    
    var mapLock = NSLock()
    
    var locationButton: MKUserTrackingBarButtonItem!
    let locationManager = CLLocationManager()
    var yelpClient: YLPClient?
    
    var busineses: [YLPBusiness]?
    var selectedBusiness: YLPBusiness?
    
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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
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
            
            self.locationManager.startUpdatingLocation()
        }
        
    }
    
    func nearest(of campuses: [Campus]) -> Campus? {
        
        guard var nearest: Campus = campuses.first else { return nil }
        var campuses = campuses.dropFirst()
        
        func distance(to campus: Campus, from location: CLLocation) -> CLLocationDistance {
            let campusLocation = CLLocation(latitude: campus.region.center.latitude, longitude: campus.region.center.longitude)
            return location.distance(from: campusLocation)
        }
        
        guard let userLocation = mapView.userLocation.location else {
            let i = campuses.index(where: { $0.id == "MN" })!
            return campuses[i]
        }
        
        var minDist: Double = distance(to: nearest, from: userLocation)
        
        for campus in campuses {
            let dist = distance(to: campus, from: userLocation)
            if dist < minDist {
                minDist = dist
                nearest = campus
            }
        }
        return nearest
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case mapsDetailSegueID:

                let mapsDetailVC = segue.destination as? MapsDetailTableViewController
                mapsDetailVC?.selectedBusiness = self.selectedBusiness

        default:
            break
        }
    }
 

}

// MARK: - CLLocationManagerDelegate
extension MapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = centerMapFirstTime
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
        
        yelpClient?.search(with: query) { (search, error) in
            if let error = error {
                log.error(error)
                return
            }
            
            if let businesses = search?.businesses {
                self.mapLock.try()
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(businesses)
                    self.busineses = businesses
                }
                
                self.mapLock.unlock()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if let oldBusinesses = self.busineses {
            mapView.removeAnnotations(oldBusinesses)
            self.busineses = nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let resultsController = searchController.searchResultsController as? MapsSearchResultsTableViewController {
            resultsController.region = mapView.region
        }
        loadBusiness(in: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let business = view.annotation as? YLPBusiness {
            selectedBusiness = business
            performSegue(withIdentifier: "showMapsDetail", sender: self)
        }
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
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: YLPBusiness, rhs: YLPBusiness) -> Bool {
        return lhs.identifier == rhs.identifier
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

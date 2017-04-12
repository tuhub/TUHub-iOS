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

let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)

class MapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    lazy var searchController: UISearchController = {
        let resultsController = MapsSearchResultsTableViewController()
        resultsController.view.backgroundColor = .clear
        resultsController.modalPresentationStyle = .overCurrentContext
        let visualEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let visualEffectView = UIVisualEffectView(effect: visualEffect)
        visualEffectView.frame = resultsController.view.bounds
        resultsController.view.insertSubview(visualEffectView, at: 0)
        
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.hidesBottomBarWhenPushed = true
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    lazy var centerMapFirstTime: Void = {
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: defaultSpan)
        self.mapView.setRegion(region, animated: false)
    }()
    
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
        
        // Retrieve campuses and their buildings
        Campus.retrieveAll { (campuses, error) in
            guard error == nil else {
                let alertController = UIAlertController(title: "Unable to Retrieve Campus Information",
                                                    message: "TUHub was unable to retrieve campus and building information from Temple's servers. Please try again shortly.",
                                                    preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss",
                                                         style: .default,
                                                         handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if let campuses = campuses, let nearest = self.nearest(of: campuses) {
                self.mapView.setRegion(nearest.region, animated: false)
            } else {
                _ = self.centerMapFirstTime
            }
            self.mapView(self.mapView, regionDidChangeAnimated: false)
        }
        
        // Set up Yelp Client
        YLPClient.authorize(withAppId: YLPClient.id, secret: YLPClient.secret) { (client, error) in
            if let error = error {
                log.error(error)
                return
            }
            self.yelpClient = client
        }
        
    }
    
    func nearest(of campuses: [Campus]) -> Campus? {
        
        guard var nearest: Campus = campuses.first else { return nil }
        var campuses = campuses.dropFirst()
        
        var minDist: Double = 0
        guard let userLocation = mapView.userLocation.location else {
            let i = campuses.index(where: { $0.id == "MN" })!
            return campuses[i]
        }
        
        for campus in campuses {
            let campusLocation = CLLocation(latitude: campus.region.center.latitude, longitude: campus.region.center.longitude)
            let dist = userLocation.distance(from: campusLocation)
            if dist < minDist {
                minDist = dist
                nearest = campus
            }
        }
        return nearest
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - CLLocationManagerDelegate
extension MapsViewController: CLLocationManagerDelegate {
    
}

// MARK: - MKMapViewDelegate
extension MapsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // Center the map the first time we get a real location change.
//        _ = centerMapFirstTime
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let coordinate = YLPCoordinate(latitude: center.latitude, longitude: center.longitude)
        
        // Set up query
        let query = YLPQuery(coordinate: coordinate)
        query.radiusFilter = Double(Int(mapView.region.radius))
        query.sort = .distance
        query.limit = 40
        
        yelpClient?.search(with: query) { (search, error) in
            if let error = error {
                log.error(error)
                return
            }
            
            if let businesses = search?.businesses {
                if let oldBusinesses = self.busineses {
                    self.mapView.removeAnnotations(oldBusinesses)
                }
                
                self.mapView.addAnnotations(businesses)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let business = view.annotation as? YLPBusiness {
            selectedBusiness = business
            // TODO: Perform segue here, use selectedBusiness to pass to detail VC
        }
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

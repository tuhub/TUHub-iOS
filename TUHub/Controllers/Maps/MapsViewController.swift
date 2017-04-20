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

let defaultCampusKey = "defaultCampus"
let defaultTransportMethod = "defaultTransport"

private let minimumLatitudeOffset = 0.001
private let minimumLongitudeOffset = 0.001
private let minimumSpanOffset = 0.001

class MapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var campuses: [Campus]?
    var selectedBuilding: Building?

    
    var locationButton: MKUserTrackingBarButtonItem!
    let locationManager = CLLocationManager()
    var yelpClient: YLPClient?
    
    lazy var businesses: [YLPBusiness] = []
    
    var hoverBar: ISHHoverBar!
    var infoButton: UIBarButtonItem!
    
    var oldRegion: MKCoordinateRegion?
    
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
    
    lazy var loadCampusesFirstTime: Void = {
        let insets = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: self.bottomLayoutGuide.length, right: 0)
        let resultsController = self.searchController.searchResultsController as? MapsSearchResultsTableViewController
        resultsController?.insets = insets
        resultsController?.delegate = self
        
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
            
            self.campuses = campuses
            self.infoButton.isEnabled = true
            
            // Add Temple buildings to the map
            for campus in campuses {
                if let buildings = campus.buildings {
                    self.mapView.addAnnotations(buildings)
                }
            }
            
            // Check if user has selected a default campus
            let defaults = UserDefaults.standard
            if let defaultCampusID = defaults.string(forKey: defaultCampusKey) {
                
                // Find the campus object corresponding to the default campus ID
                if let i = campuses.index(where: { $0.id == defaultCampusID }) {
                    let campus = campuses[i]
                    
                    // Set campus as mapView's region
                    DispatchQueue.main.async {
                        self.didChangeCampus(to: campus)
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
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Put search bar in navigation bar
        navigationItem.titleView = searchController.searchBar
        
        // Set up toolbar
        hoverBar = ISHHoverBar(frame: CGRect(x: 0, y: 0, width: 44, height: 88))
        
        infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "InfoIcon"), style: .plain, target: self, action: #selector(showMapsOptions))
        infoButton.isEnabled = false
        
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
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
        
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
        _ = loadCampusesFirstTime
    }
    
    func showDefaultCampusSelection(_ campuses: [Campus]) {
        let actionSheet = UIAlertController(title: "Select Your Default Campus", message: "Select the campus that you would like to be displayed when you first open the app.", preferredStyle: .actionSheet)
        
        var frame = hoverBar.frame
        frame.size = CGSize(width: frame.size.width, height: frame.size.height / 2)
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = frame
        
        for campus in campuses {
            let action = UIAlertAction(title: campus.name, style: .default) { (action) in
                
                // Save selection to user defaults
                let defaults = UserDefaults.standard
                defaults.set(campus.id, forKey: defaultCampusKey)
                
                // Show selection on map
                DispatchQueue.main.async {
                    self.didChangeCampus(to: campus)
                }
                
            }
            actionSheet.addAction(action)
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showMapsOptions() {
        guard let mapsOptionsVC = storyboard?.instantiateViewController(withIdentifier: "MapsOptionsVC") as? MapsOptionsViewController else { return }
        
        mapsOptionsVC.campuses = self.campuses
        mapsOptionsVC.mapType = self.mapView.mapType
        mapsOptionsVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: mapsOptionsVC)
        if traitCollection.horizontalSizeClass == .compact {
            navVC.modalPresentationStyle = .overFullScreen
        } else {
            navVC.modalPresentationStyle = .popover
        }
        
        var frame = hoverBar.frame
        frame.size = CGSize(width: frame.size.width, height: frame.size.height / 2)
        navVC.popoverPresentationController?.sourceView = self.view
        navVC.popoverPresentationController?.sourceRect = frame
        present(navVC, animated: true, completion: nil)
    }
    
    func calculateDirections(to location: Location) {
        // Only perform directions if user's location is available
        guard let userLocation = mapView.userLocation.location else { return }
        
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        
        // Determine transport type
        // Save selection to user defaults
        let defaults = UserDefaults.standard
        var method: MKDirectionsTransportType = .any
        if let saved = defaults.object(forKey: defaultTransportMethod) as? Int {
            method = MKDirectionsTransportType(rawValue: UInt(saved))
        }
        request.transportType = method
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                log.error(error)
                return
            }
            guard let route = response?.routes.first else { return }
            self.plotPolyline(of: route)
        }
    }
    
    func plotPolyline(of route: MKRoute) {
        // Remove any overlays currently on the map
        if mapView.overlays.count > 0 {
            mapView.removeOverlays(mapView.overlays)
        }
        
        // Add our overlay
        mapView.add(route.polyline)
        
        // Zoom out to fit the route on the map
        mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                  edgePadding: UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0),
                                  animated: false)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case mapsDetailSegueID:
            guard let location  = sender as? Location,
                let yelpClient = self.yelpClient,
                let mapsDetailVC = segue.destination as? MapsDetailViewController
                else { break }
                mapsDetailVC.location = location
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
            
            if let businesses = search?.businesses.filter({ !$0.isClosed }) {
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(businesses)
                    self.businesses.append(contentsOf: businesses)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            polylineRenderer.strokeColor = UIColor.cherry.withAlphaComponent(0.75)
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Check the offset between the old region and the new one, don't load new businesses if too small
        if let oldRegion = self.oldRegion {
            let newRegion = mapView.region
            let latOffset = abs(oldRegion.center.latitude - newRegion.center.latitude)
            let longOffset = abs(oldRegion.center.longitude - newRegion.center.longitude)
            let spanOffset = max(abs(oldRegion.span.latitudeDelta - newRegion.span.latitudeDelta), abs(oldRegion.span.longitudeDelta - newRegion.span.longitudeDelta))
            
            if latOffset < minimumLatitudeOffset && longOffset < minimumLongitudeOffset && spanOffset < minimumSpanOffset {
                return
            }
        }

        self.oldRegion = mapView.region
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let location = view.annotation as? Location {
            calculateDirections(to: location)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if view.annotation is Location {
            self.performSegue(withIdentifier: mapsDetailSegueID, sender: view.annotation)
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

extension MapsViewController: MapsSearchResultsTableViewControllerDelegate {
    func didSelect(location: Location) {
        searchController.isActive = false
        mapView.addAnnotation(location)
        mapView.setCenter(location.coordinate, animated: true)
        mapView.selectAnnotation(location, animated: true)
    }
}

extension MapsViewController: MapsOptionsViewControllerDelegate {
    func didChangeMapType(to mapType: MKMapType) {
        mapView.mapType = mapType
    }
    
    func didChangeCampus(to campus: Campus) {
        mapView.setRegion(campus.region, animated: true)
        loadBusiness(in: campus.region)
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

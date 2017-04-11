//
//  MapsViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ISHHoverBar

class MapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationButton: MKUserTrackingBarButtonItem!

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
    
    let locationManager = CLLocationManager()
    
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
        
        // Location manager set up
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
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

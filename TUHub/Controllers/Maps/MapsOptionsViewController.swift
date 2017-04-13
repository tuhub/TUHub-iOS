//
//  MapsOptionsViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/13/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka
import MapKit

protocol MapsOptionsViewControllerDelegate {
    func didChangeCampus(to campus: Campus)
    func didChangeMapType(to mapType: MKMapType)
}

class MapsOptionsViewController: FormViewController {

    var delegate: MapsOptionsViewControllerDelegate!
    
    var campuses: [Campus]!
    var mapType: MKMapType!
    
    private let defaults = UserDefaults.standard
    let mapTypeStrings: [(String, MKMapType)] = [
        ("Standard", .standard),
        ("Hybrid", .hybrid),
        ("Satellite", .satellite)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        
        (form
            +++ Section("Campus")
            // Campus row
            <<< ActionSheetRow<String>("defaultCampusRow") {
                $0.title = "Default Campus"
                let options: [String] = self.campuses.map { $0.name }
                $0.options = options
                
                $0.cell.backgroundColor = .clear
                
                if let defaultCampusID = self.defaults.string(forKey: defaultCampusKey), let i = campuses.index(where: { $0.id == defaultCampusID }) {
                
                    let campus = self.campuses[i]
                    $0.value = campus.name
                }
            }.onChange { (row) in
                if let i = self.campuses.index(where: { $0.name == row.value! }) {
                    let campus = self.campuses[i]
                    self.defaults.set(campus.id, forKey: defaultCampusKey)
                    self.delegate.didChangeCampus(to: campus)
                }
            }
            
            +++ Section("Map Type")
            <<< SegmentedRow<String>("mapType") {
                $0.options = self.mapTypeStrings.map { $0.0 }
                
                $0.cell.backgroundColor = .clear
                
                if let i = self.mapTypeStrings.index(where: { $0.1 == self.mapType }) {
                    $0.value = self.mapTypeStrings[i].0
                }
            }.onChange { (row) in
                let val = row.value
                if let i = self.mapTypeStrings.index(where: { $0.0 == val }) {
                    self.mapType = self.mapTypeStrings[i].1
                    self.delegate.didChangeMapType(to: self.mapType)
                }
            }
        )
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
//        self.preferredContentSize = CGSize(width: 300, height: 200)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.preferredContentSize = tableView.contentSize
    }


    @IBAction func didPressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

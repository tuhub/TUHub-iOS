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
    func didChangeTransportType(to: MKDirectionsTransportType)
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
        
        tableView?.backgroundColor = .clear
        
        (form
            
            +++ SelectableSection<ListCheckRow<String>>("Campus", selectionType: .singleSelection(enableDeselection: false))
            
            +++ Section("Transportation Type")
            <<< SegmentedRow<String>("transportRow") {
                
                let types: [MKDirectionsTransportType] = [MKDirectionsTransportType.automobile,
                                                          MKDirectionsTransportType.walking,
                                                          MKDirectionsTransportType.transit]
                let current = MKDirectionsTransportType(rawValue:(defaults.object(forKey: defaultTransportMethodKey) as? UInt) ?? MKDirectionsTransportType.walking.rawValue)
                
                $0.options = types.flatMap { $0.name }
                $0.value = current.name
                $0.cell.backgroundColor = .clear
                }.onChange { (row) in
                    if let val = row.value, let selectedType = MKDirectionsTransportType.type(for: val) {
                        self.defaults.set(selectedType.rawValue, forKey: defaultTransportMethodKey)
                        self.delegate.didChangeTransportType(to: selectedType)
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
        
        let campuses = self.campuses.map { $0.name }
        let campusSection = form.first! as! SelectableSection<ListCheckRow<String>>
        let current = self.campuses.first(where: { $0.id == defaults.string(forKey: defaultCampusKey) })
        for option in campuses {
            campusSection <<< ListCheckRow<String>(option) {
                $0.title = option
                $0.selectableValue = option
                $0.cell.tintColor = .cherry
                $0.cell.backgroundColor = .clear
                $0.value = current?.name == $0.selectableValue ? "" : nil
            }
        }
        campusSection.onSelectSelectableRow = { (cell, row) in
            if let campus = self.campuses.first(where: { $0.name == row.selectableValue! }) {
                self.defaults.set(campus.id, forKey: defaultCampusKey)
                self.delegate.didChangeCampus(to: campus)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView?.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.preferredContentSize = (tableView?.contentSize)!
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

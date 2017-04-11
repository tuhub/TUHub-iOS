//
//  Campus.swift
//  TUHub
//
//  Created by Connor Crawford on 4/11/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

private let campuses = "MN,AMB,CC,HSC,JPN"

class Campus {
    
    private(set) var id: String
    private(set) var name: String
    private(set) var northWestLatitude: Double
    private(set) var northWestLongitude: Double
    private(set) var southEastLatitude: Double
    private(set) var southEastLongitude: Double
    lazy var region: MKCoordinateRegion = {
        // Calculate span
        let latDelta = abs(self.northWestLatitude - self.southEastLatitude)
        let longDelta = abs(self.northWestLongitude - self.southEastLongitude)
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // Calculate center
        let centerLat = (self.northWestLatitude + self.southEastLatitude) / 2
        let centerLong = (self.northWestLongitude + self.southEastLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        return MKCoordinateRegion(center: center, span: span)
    }()
//    private(set) var buildings: []
    
    init?(json: JSON) {
        guard
            let id = json["id"].string,
            let name = json["name"].string,
            let northWestLatitude = json["northWestLatitude"].double,
            let northWestLongitude = json["northWestLongitude"].double,
            let southEastLatitude = json["southEastLatitude"].double,
            let southEastLongitude = json["southEastLongitude"].double
            else {
                log.error("Unable to parse campus")
                return nil
        }
        
        self.id = id
        self.name = name
        self.northWestLatitude = northWestLatitude
        self.northWestLongitude = northWestLongitude
        self.southEastLatitude = southEastLatitude
        self.southEastLongitude = southEastLongitude
        
    }
    
    class func retrieveAll(_ responseHandler: @escaping ([Campus]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .maps, pathParameters: [campuses])
        { (data, error) in
            
            var campuses: [Campus]?
            
            defer { responseHandler(campuses, error) }
            guard let data = data, error == nil else { return }
            let json = JSON(data: data)
            
            if let campusesJSON = json["campuses"].array {
                campuses = campusesJSON.flatMap { Campus(json: $0) }
            }
        }
    }
}

//
//  Building.swift
//  TUHub
//
//  Created by Connor Crawford on 4/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class Building: NSObject {
    var id: String
    var coordinate: CLLocationCoordinate2D
    var source: String
    var name: String
    var campusID: String
    var desc: String?
    var imageURL: String?
    var address: String?
    
    init?(json: JSON) {
        guard
            let id = json["id"].string,
            let lat = json["latitude"].double,
            let long = json["longitude"].double,
            let source = json["source"].string,
            let name = json["name"].string,
            let campusID = json["campusId"].string
            else {
                log.error("Unable to parse Building")
                return nil
        }
        
        self.id = id
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.source = source
        self.name = name
        self.campusID = campusID
        self.desc = json["longDescription"].string
        self.imageURL = json["imageUrl"].string
        self.address = json["address"].string
    }
    
}

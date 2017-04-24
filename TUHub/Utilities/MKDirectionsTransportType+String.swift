//
//  MKDirectionsTransportType+String.swift
//  TUHub
//
//  Created by Connor Crawford on 4/24/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import MapKit

extension MKDirectionsTransportType {
    
    static func type(for name: String) -> MKDirectionsTransportType? {
        switch name {
        case MKDirectionsTransportType.automobile.name!:
            return MKDirectionsTransportType.automobile
        case MKDirectionsTransportType.walking.name!:
            return MKDirectionsTransportType.walking
        case MKDirectionsTransportType.transit.name!:
            return MKDirectionsTransportType.transit
        default:
            return nil
        }
    }
    
    var name: String? {
        switch self {
        case MKDirectionsTransportType.automobile:
            return "Driving"
        case MKDirectionsTransportType.walking:
            return "Walking"
        case MKDirectionsTransportType.transit:
            return "Transit"
        default:
            return nil
        }
    }
    
}

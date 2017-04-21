//
//  Location.swift
//  TUHub
//
//  Created by Connor Crawford on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation
import YelpAPI
import MapKit

protocol Location: MKAnnotation, TableViewDisplayable {
    var address: String? { get }
    var imageURLs: [URL]? { get }
}

extension YLPBusiness: Location {
    
    var imageURLs: [URL]? {
        var urls: [URL] = []
        if let yelpImageURL = imageURL {
            urls.append(yelpImageURL)
        }
        if let streetViewURL = URL(string: "https://maps.googleapis.com/maps/api/streetview?size=592x333&location=\(self.coordinate.latitude),\(self.coordinate.longitude)&key=\(StreetViewAPI.key)") {
            urls.append(streetViewURL)
        }
        return urls
    }
    
    var address: String? {
        var addr = ""
        for (i, line) in location.address.enumerated() {
            addr += "\(line)"
            if i == location.address.count - 1 {
                addr += "\n"
            } else {
                addr += ", "
            }
        }
        addr += "\(location.city), \(location.stateCode)\n"
        addr += "\(location.postalCode)"
        return addr
    }
    
}

extension Building: Location {
}

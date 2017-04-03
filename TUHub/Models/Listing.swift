//
//  Listing.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter
}()

class Listing {
    
    var id: String!
    var title: String
    var description: String
    var datePosted: Date
    var ownerID: String
    var isActive: Bool
    var photos: (reference: String, isFolder: Bool)?
    
    required init?(json: JSON) {
        guard
            let title = json["title"].string,
            let description = json["description"].string,
            let datePostedStr = json["datePosted"].string,
            let datePosted = dateFormatter.date(from: datePostedStr),
            let ownerID = json["ownerId"].string,
            let isActive = json["isActive"].string
            else { return nil }
        
        self.title = title
        self.description = description
        self.datePosted = datePosted
        self.ownerID = ownerID
        self.isActive = isActive == "true"
        
        if let photosFolder = json["picFolder"].string {
            photos = (reference: photosFolder, isFolder: true)
        } else if let photoFilename = json["picFileName"].string {
            photos = (reference: photoFilename, isFolder: false)
        }
        
    }
    
}

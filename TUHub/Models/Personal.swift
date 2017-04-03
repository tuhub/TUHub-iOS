//
//  Personal.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

class Personal: Listing {
    
    var location: String
    
    required init?(json: JSON) {
        guard
            let id = json["personalId"].string,
            let location = json["location"].string
            else { return nil }
        
        self.location = location
        
        super.init(json: json)
        
        self.id = id
    }
    
}

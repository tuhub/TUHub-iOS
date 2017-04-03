//
//  Personal.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

class Product: Listing {
    
    var price: String
    
    required init?(json: JSON) {
        guard
            let id = json["productId"].string,
            let price = json["price"].string
            else { return nil }
        
        self.price = price
        
        super.init(json: json)
        
        self.id = id
    }
    
}

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
    
    class func retrieveAll(_ responseHandler: @escaping ([Product]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_products.jsp"],
                                      queryParameters: ["activeOnly" : "true"])
        { (data, error) in
            
            var products: [Product]?
            
            defer { responseHandler(products, error) }
            guard let data = data else { return }
            let json = JSON(data)
            
            if let productsJSON = json["productList"].array {
                products = productsJSON.flatMap { Product(json: $0) }
            }
        }
    }
    
}

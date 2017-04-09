//
//  Personal.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

private let pageSize = 15

class Product: Listing {
    
    fileprivate(set) var price: String!
    
    required init?(json: JSON) {
        guard
            let id = json["productId"].string,
            let price = json["price"].string
            else {
                log.error("Unable to parse Product")
                return nil
        }
        
        self.price = price
        
        super.init(json: json)
        
        self.id = id
    }
    
    init(title: String, desc: String?, ownerID: String, photosDir: String?, price: Double) {
        self.price = String(format: "%.02f", locale: Locale.current, arguments: [price])
        super.init(title: title, desc: desc, ownerID: ownerID, photosDir: photosDir)
    }
    
    override func post(_ responseHandler: @escaping (_ listingID: String?, Error?) -> Void) {
        
        var qParams: [String : Any] = ["title" : title,
                                       "price" : price,
                                       "isActive" : "true",
                                       "ownerId" : ownerID]
        
        if let desc = description {
            qParams["description"] = desc
        }
                
        NetworkManager.shared.request(toEndpoint: .marketplace, pathParameters: ["insert_product.jsp"], queryParameters: qParams) { (data, error) in
            
            guard let data = data else { responseHandler(nil, error); return }
            
            let json = JSON(data: data)
            let errorStr = json["error"].string
            if errorStr == nil || errorStr!.characters.count == 0 {
                // Successfully posted, now go get the post ID to get the photo directory
                Product.retrieve(belongingTo: self.ownerID) { (products, error) in
                    if let product = products?.first {
                        responseHandler(product.photosDirectory!, error)
                    }
                }
            } else {
                responseHandler(nil, error)
            }
            
        }
    }
    
    private class func handle(response data: Data?, error: Error?, _ responseHandler: @escaping ([Product]?, Error?) -> Void) {
        var products: [Product]?
        
        defer { responseHandler(products, error) }
        guard let data = data else { return }
        let json = JSON(data)
        
        if let productsJSON = json["productList"].array {
            products = productsJSON.flatMap { Product(json: $0) }
        }
    }
    
    class func retrieve(belongingTo userID: String, _ responseHandler: @escaping ([Product]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["find_products_by_user_id.jsp"],
                                      queryParameters: ["userId" : userID])
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func retrieveAll(onlyActive: Bool = false, startIndex: Int = 0, _ responseHandler: @escaping ([Product]?, Error?) -> Void) {
        let qParams: [String : Any] = ["activeOnly" : onlyActive ? "true" : "false",
                                       "offset" : startIndex,
                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_products.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func search(for searchTerms: String, startIndex: Int = 0, _ responseHandler: @escaping ([Product]?, Error?) -> Void) {
        let qParams: [String : Any] = ["title" : searchTerms,
                                       "offset" : startIndex,
                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["search_active_product_titles.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
}

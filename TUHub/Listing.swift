//
//  Listing.swift
//  TUHub
//
//  Created by Connor Crawford on 3/31/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation
import AWSDynamoDB

private let tableName = "Listing"
private let pageSize: NSNumber = 20

class Listing: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var listingId: String?
    var timestamp: NSNumber?
    var text: String?
    var title: String?
    var imageURLs: [String]?
    
    class func dynamoDBTableName() -> String {
        
        return "tuhub-mobilehub-13900767-Listings"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "listingId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "timestamp"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "listingId" : "listingId",
            "timestamp" : "timestamp",
            "text" : "text",
            "title" : "title",
            "imageURLs": "imageURLs"
        ]
    }
}


extension Listing {
    
    private static var lock = NSLock()
    private static var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    private static var doneLoading = false
    
    static func retrievePage(_ startFromBeginning: Bool, _ responseHandler: @escaping ([Listing], Error?) -> Void) {
        DatabaseManager<Listing>.retrievePage(lastEvaluatedKey,
                                     startFromBeginning,
                                     pageSize) { (results, lastEvalKey, error) in
                                        self.lastEvaluatedKey = lastEvalKey
                                        responseHandler(results, error)
        
        }
        
    }
    
}

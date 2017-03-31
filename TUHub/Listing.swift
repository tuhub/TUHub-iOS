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
    var listingID: String?
    var title: String?
    var text: String?
    var imageURLS: [String]?
    
    class func dynamoDBTableName() -> String {
        return tableName
    }
    
    class func hashKeyAttribute() -> String {
        return "listingID"
    }
    
    func save() {
        
    }
}

extension Listing {
    
    private static var lock = NSLock()
    private static var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    private static var doneLoading = false
    
    static func retrievePage(_ startFromBeginning: Bool, _ responseHandler: @escaping ([Listing], Error?) -> Void) {
        DatabaseManager.retrievePage(lastEvaluatedKey,
                                     startFromBeginning,
                                     pageSize) { (results, lastEvalKey, error) in
                                        self.lastEvaluatedKey = lastEvalKey
                                        responseHandler(results as! [Listing], error)
        }
    }
    
}

//
//  DatabaseManager.swift
//  TUHub
//
//  Created by Connor Crawford on 3/31/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import AWSDynamoDB

class DatabaseManager<ModelClass: AWSDynamoDBObjectModel> {
    
    class func describe(table: String) -> AWSTask<AnyObject> {
        let dynamoDB = AWSDynamoDB.default()
        
        // See if the test table exists.
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput?.tableName = table
        return dynamoDB.describeTable(describeTableInput!) as! AWSTask<AnyObject>
    }
    
    class func save(model: AWSDynamoDBObjectModel, _ responseHandler: ((AWSTask<AnyObject>) -> Void)?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.save(model)
        AWSTask<AnyObject>(forCompletionOfAllTasks: [task]).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = task.error {
                print("Error: \(error)")
            }
            
            responseHandler?(task)
            return nil
        }
    }
    
    static func retrievePage(
        _ lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?,
        _ startFromBeginning: Bool,
        _ pageSize: NSNumber,
        _ responseHandler: @escaping ([ModelClass], [String : AWSDynamoDBAttributeValue]?, Error?) -> Void) {
        
        var lastEvaluatedKey = lastEvaluatedKey
        
        if startFromBeginning {
            lastEvaluatedKey = nil;
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        queryExpression.exclusiveStartKey = lastEvaluatedKey
        queryExpression.limit = pageSize
        dynamoDBObjectMapper.scan(ModelClass.self, expression: queryExpression)
            .continueWith(executor: AWSExecutor.mainThread()) { (task) -> AnyObject! in
                
                var results = [ModelClass]()
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [ModelClass] {
                        results.append(item)
                    }
                    
                    lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Get error, log it if it exists
                let error: Error? = {
                    if let error = task.error {
                        log.error(error)
                        return error
                    }
                    return nil
                }()
                
                responseHandler(results, lastEvaluatedKey, error)
                
                return nil
        }
        
    }
    
}

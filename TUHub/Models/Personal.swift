//
//  Personal.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

private let pageSize = 15

class Personal: Listing {
    
    fileprivate(set) var location: String!
    
    required init?(json: JSON) {
        guard
            let id = json["personalId"].string,
            let location = json["location"].string
            else {
                log.error("Unable to parse Personal")
                return nil
        }
        
        self.location = location
        
        super.init(json: json)
        
        self.id = id
    }
    
    init(title: String, desc: String?, ownerID: String, photosDir: String?, location: String?) {
        self.location = location
        super.init(title: title, desc: desc, ownerID: ownerID, photosDir: photosDir)
    }
    
    override func post(_ responseHandler: @escaping (Error?) -> Void) {
        
        var qParams: [String : Any] = ["title" : title,
                                       "isActive" : "true",
                                       "ownerId" : ownerID]
        
        if let desc = description {
            qParams["description"] = desc
        }
        
        if let loc = location {
            qParams["location"] = loc
        }
        
        NetworkManager.shared.request(toEndpoint: .marketplace, pathParameters: ["insert_personal.jsp"], queryParameters: qParams) { (data, error) in
            debugPrint(data ?? "")
            debugPrint(error ?? "")
            responseHandler(error)
        }
    }
    
    private class func handle(response data: Data?, error: Error?, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        var personals: [Personal]?
        
        defer { responseHandler(personals, error) }
        guard let data = data else { return }
        let json = JSON(data)
        
        if let personalsJSON = json["personalList"].array {
            personals = personalsJSON.flatMap { Personal(json: $0) }
        }
    }
    
    class func retrieveAll(onlyActive: Bool = false, startIndex: Int = 0, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        let qParams: [String : Any] = ["activeOnly" : onlyActive ? "true" : "false",
                                       "offset" : startIndex,
                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_personals.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func search(for searchTerms: String, startIndex: Int = 0, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        let qParams: [String : Any] = ["title" : searchTerms,
                                       "offset" : startIndex,
                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["search_active_personal_titles.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
}

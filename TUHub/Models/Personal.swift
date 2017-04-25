//
//  Personal.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

//private let pageSize = 15

class Personal: Listing {
    
    var location: String?
    
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
    
    override func post(_ responseHandler: @escaping (_ listingID: String?, Error?) -> Void) {
        
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
            
            guard let data = data else { responseHandler(nil, error); return }
            
            let json = JSON(data: data)
            debugPrint(json)
            let errorStr = json["error"].string
            if errorStr == nil || errorStr!.characters.count == 0 {
                // Successfully posted, now go get the post ID to get the photo directory
                Personal.retrieve(belongingTo: self.ownerID) { (personals, error) in
                    if let personal = personals?.first {
                        responseHandler(personal.photosDirectory!, error)
                    }
                }
            } else {
                responseHandler(nil, error)
            }
        }
    }
    
    override func update(_ responseHandler: @escaping (Error?) -> Void) {
        
        var qParams: [String : Any] = ["title" : title,
                                       "isActive" : isActive ? "true" : "false",
                                       "personalId" : id]
        
        if let desc = description {
            qParams["description"] = desc
        }
        
        if let loc = location {
            qParams["location"] = loc
        }
        
        NetworkManager.shared.request(toEndpoint: .marketplace, pathParameters: ["update_personal.jsp"], queryParameters: qParams) { (data, error) in
            defer { responseHandler(error) }
            guard let data = data else { return }
            let json = JSON(data)
            
            debugPrint(json)
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
    
    class func retrieve(belongingTo userID: String, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["find_personals_by_user_id.jsp"],
                                      queryParameters: ["userId" : userID])
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func retrieveAll(onlyActive: Bool = true, startIndex: Int = 0, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        let qParams: [String : Any] = ["activeOnly" : onlyActive ? "true" : "false"]
//                                       "offset" : startIndex,
//                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_personals.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func search(for searchTerms: String, startIndex: Int = 0, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        let qParams: [String : Any] = ["title" : searchTerms]
//                                       "offset" : startIndex,
//                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["search_active_personal_titles.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
}

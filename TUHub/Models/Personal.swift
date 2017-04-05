//
//  Personal.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

class Personal: Listing {
    
    fileprivate(set) var location: String
    
    required init?(json: JSON) {
        guard
            let id = json["personalId"].string,
            let location = json["location"].string
            else { return nil }
        
        self.location = location
        
        super.init(json: json)
        
        self.id = id
    }
    
    class func retrieveAll(onlyActive: Bool = true, _ responseHandler: @escaping ([Personal]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_personals.jsp"],
                                      queryParameters: ["activeOnly" : onlyActive ? "true" : "false"])
        { (data, error) in
            
            var personals: [Personal]?
            
            defer { responseHandler(personals, error) }
            guard let data = data else { return }
            let json = JSON(data)
            
            if let personalsJSON = json["jobList"].array {
                personals = personalsJSON.flatMap { Personal(json: $0) }
            }
        }
    }
    
}

//
//  MarketplaceUser.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct MarketplaceUser {
    fileprivate(set) var userId: String
    fileprivate(set) var email: String
    fileprivate(set) var firstName: String
    fileprivate(set) var lastName: String
    fileprivate(set) var phoneNumber: String
    
    init?(json: JSON) {
        guard
            let userId = json["tuId"].string,
            let email = json["email"].string,
            let firstName = json["firstName"].string,
            let lastName = json["lastName"].string,
            let phoneNumber = json["phoneNumber"].string
            else { return nil }
        
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
    
    static func retrieve(user userId: String, _ responseHandler: @escaping (MarketplaceUser?, Error?)->Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace, pathParameters: ["select_user_by_id.jsp"], queryParameters: ["userId" : userId]) { (data, error) in
            var user: MarketplaceUser?
            guard let data = data else { return }
            defer { responseHandler(user, error) }
            
            let json = JSON(data)
            if let usersJSON = json["userList"].array, let userJSON = usersJSON.first {
                user = MarketplaceUser(json: userJSON)
            }
        }
    }
}

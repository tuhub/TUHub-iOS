//
//  Job.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter
}()

class Job: Listing {
    
    var location: String
    var hoursPerWeek: Int
    var pay: String
    var startDate: Date
    
    required init?(json: JSON) {
        guard
            let id = json["jobId"].string,
            let location = json["location"].string,
            let hoursPerWeek = json["hoursPerWeek"].int,
            let pay = json[""].string,
            let startDateStr = json[""].string,
            let startDate = dateFormatter.date(from: startDateStr)
            else { return nil }
        
        self.location = location
        self.hoursPerWeek = hoursPerWeek
        self.pay = pay
        self.startDate = startDate
        
        super.init(json: json)
        
        self.id = id
    }
}

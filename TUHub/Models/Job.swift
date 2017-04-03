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
            let hoursPerWeekStr = json["hoursPerWeek"].string,
            let hoursPerWeek = Int(hoursPerWeekStr),
            let pay = json["pay"].string,
            let startDateStr = json["startDate"].string,
            let startDate = dateFormatter.date(from: startDateStr)
            else { return nil }
        
        self.location = location
        self.hoursPerWeek = hoursPerWeek
        self.pay = pay
        self.startDate = startDate
        
        super.init(json: json)
        
        self.id = id
    }
    
    class func retrieveAll(_ responseHandler: @escaping ([Job]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_jobs.jsp"],
                                      queryParameters: ["activeOnly" : "false"])
        { (data, error) in
            
            var jobs: [Job]?
            
            defer { responseHandler(jobs, error) }
            guard let data = data else { return }
            let json = JSON(data)
            
            if let jobsJSON = json["jobList"].array {
                jobs = jobsJSON.flatMap { Job(json: $0) }
            }
        }
    }
}

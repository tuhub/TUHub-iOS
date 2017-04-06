//
//  Job.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

private let pageSize = 15

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter
}()

class Job: Listing {
    
    fileprivate(set) var location: String
    fileprivate(set) var hoursPerWeek: Int?
    fileprivate(set) var pay: String
    fileprivate(set) var startDate: Date
    
    required init?(json: JSON) {
        guard
            let id = json["jobId"].string,
            let location = json["location"].string,
            let hoursPerWeek = json["hoursPerWeek"].int,
            let pay = json["pay"].string,
            let startDateStr = json["startDate"].string,
            let startDate = dateFormatter.date(from: startDateStr)
            else { return nil }
        
        self.location = location
        self.hoursPerWeek = hoursPerWeek < 0 ? nil : hoursPerWeek
        self.pay = pay
        self.startDate = startDate
        
        super.init(json: json)
        
        self.id = id
    }
    
    class func retrieveAll(onlyActive: Bool = false, startIndex: Int = 0, _ responseHandler: @escaping ([Job]?, Error?) -> Void) {
        let qParams: [String : Any] = ["activeOnly" : onlyActive ? "true" : "false",
                                      "offset" : startIndex,
                                      "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_jobs.jsp"],
                                      queryParameters: qParams)
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

//
//  Job.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

//private let pageSize = 15

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter
}()

private let postDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy"
    return dateFormatter
}()

class Job: Listing {
    
    var location: String?
    var hoursPerWeek: Int
    var pay: String!
    var startDate: Date!
    
    required init?(json: JSON) {
        guard
            let id = json["jobId"].string,
            let hoursPerWeek = json["hoursPerWeek"].int,
            let pay = json["pay"].string,
            let startDateStr = json["startDate"].string,
            let startDate = dateFormatter.date(from: startDateStr)
            else {
                log.error("Unable to parse Job")
                return nil
        }
        
        location = json["location"].string
        self.hoursPerWeek = hoursPerWeek
        self.pay = pay
        self.startDate = startDate
        
        super.init(json: json)
        
        self.id = id
    }
    
    init(title: String, desc: String?, ownerID: String, photosDir: String?, location: String?, hours: Int, pay: Double, startDate: Date) {
        self.location = location
        self.hoursPerWeek = hours
        self.pay = String(format: "%.02f", locale: Locale.current, arguments: [pay])
        self.startDate = startDate
        super.init(title: title, desc: desc, ownerID: ownerID, photosDir: photosDir)
    }
    
    override func post(_ responseHandler: @escaping (_ listingID: String?, Error?) -> Void) {
        
        var qParams: [String : Any] = ["title" : title,
                                       "pay" : pay,
                                       "hoursPerWeek" : hoursPerWeek,
                                       "startDate" : postDateFormatter.string(from: startDate),
                                       "isActive" : "true",
                                       "ownerId" : ownerID]
        
        if let desc = description {
            qParams["description"] = desc
        }
        
        if let loc = location {
            qParams["location"] = loc
        }
        
        NetworkManager.shared.request(toEndpoint: .marketplace, pathParameters: ["insert_job.jsp"], queryParameters: qParams) { (data, error) in
            
            guard let data = data else { responseHandler(nil, error); return }
            
            let json = JSON(data: data)
            let errorStr = json["error"].string
            if errorStr == nil || errorStr!.characters.count == 0 {
                // Successfully posted, now go get the post ID to get the photo directory
                Job.retrieve(belongingTo: self.ownerID) { (jobs, error) in
                    if let job = jobs?.first {
                        responseHandler(job.photosDirectory!, error)
                    } else {
                        responseHandler(nil, error)
                    }
                }
            } else {
                responseHandler(nil, error)
            }
        }
    }
    
    override func update(_ responseHandler: @escaping (Error?) -> Void) {
        
        var qParams: [String : Any] = ["title" : title,
                                       "pay" : pay,
                                       "hoursPerWeek" : hoursPerWeek,
                                       "startDate" : postDateFormatter.string(from: startDate),
                                       "isActive" : isActive ? "true" : "false",
                                       "jobId" : id]
        
        if let desc = description {
            qParams["description"] = desc
        }
        
        if let loc = location {
            qParams["location"] = loc
        }
        
        NetworkManager.shared.request(toEndpoint: .marketplace, pathParameters: ["update_job.jsp"], queryParameters: qParams) { (data, error) in
            defer { responseHandler(error) }
            guard let data = data else { return }
            let json = JSON(data)
            
            debugPrint(json)
        }
    }
    
    private class func handle(response data: Data?, error: Error?, _ responseHandler: @escaping ([Job]?, Error?) -> Void) {
        guard let data = data else { return }
        let json = JSON(data)
        
        var jobs: [Job]?
        if let jobsJSON = json["jobList"].array {
            jobs = jobsJSON.flatMap { Job(json: $0) }
        }
        responseHandler(jobs, error)
    }
    
    class func retrieve(belongingTo userID: String, _ responseHandler: @escaping ([Job]?, Error?) -> Void) {
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["find_jobs_by_user_id.jsp"],
                                      queryParameters: ["userId" : userID])
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func retrieveAll(onlyActive: Bool = true, startIndex: Int = 0, _ responseHandler: @escaping ([Job]?, Error?) -> Void) {
        let qParams: [String : Any] = ["activeOnly" : onlyActive ? "true" : "false"]
//                                      "offset" : startIndex,
//                                      "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["select_all_jobs.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
    
    class func search(for searchTerms: String, startIndex: Int = 0, _ responseHandler: @escaping ([Job]?, Error?) -> Void) {
        let qParams: [String : Any] = ["title" : searchTerms]
//                                       "offset" : startIndex,
//                                       "limit" : pageSize]
        NetworkManager.shared.request(fromEndpoint: .marketplace,
                                      pathParameters: ["search_active_job_titles.jsp"],
                                      queryParameters: qParams)
        { (data, error) in
            handle(response: data, error: error, responseHandler)
        }
    }
}

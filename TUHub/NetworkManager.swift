//
//  NetworkManager.swift
//  TUHub
//
//  Created by Connor Crawford on 2/13/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NetworkManager: NSObject {
    
    enum Endpoint: String {
        case grades = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/grades"
        case courseOverview = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/overview"
        case courseFullView = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/fullview"
        // case courseCalendarView = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/calendarview/" // This endpoint only gives this current week's schedule, which we are unlikely to use.
        case courseRoster = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/roster"
        case getUserInfo = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/security/getUserInfo"
        case news = "https://prd-mobile.temple.edu/banner-mobileserver/rest/1.2/feed"
    }
    
    typealias ResponseHandler = (JSON?, Error?) -> Void
    
    static func request(fromEndpoint endpoint: Endpoint,
                        _ responseHandler: ResponseHandler?) {
        
        NetworkManager.request(url: endpoint.rawValue, withTUID: nil, arguments: nil, authenticateWith: nil, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: Endpoint,
                        arguments: [String],
                        _ responseHandler: ResponseHandler?) {
        
        NetworkManager.request(url: endpoint.rawValue, withTUID: nil, arguments: arguments, authenticateWith: nil, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: Endpoint,
                        authenticateWith credential: Credential,
                        _ responseHandler: ResponseHandler?) {
        
        NetworkManager.request(url: endpoint.rawValue, withTUID: nil, arguments: nil, authenticateWith: credential, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: Endpoint,
                        arguments: [String],
                        authenticateWith credential: Credential,
                        _ responseHandler: ResponseHandler?) {
        
        NetworkManager.request(url: endpoint.rawValue, withTUID: nil, arguments: arguments, authenticateWith: credential, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: Endpoint,
                        withTUID tuID: String,
                        authenticateWith credential: Credential,
                        _ responseHandler: ResponseHandler?) {
        
        NetworkManager.request(url: endpoint.rawValue, withTUID: tuID, arguments: nil, authenticateWith: nil, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: Endpoint,
                        withTUID tuID: String,
                        arguments: [String],
                        authenticateWith credential: Credential,
                        _ responseHandler: ResponseHandler?) {
        
        NetworkManager.request(url: endpoint.rawValue, withTUID: tuID, arguments: arguments, authenticateWith: nil, responseHandler)
    }
    
    private static func request(url: String,
                                withTUID tuID: String?,
                                arguments: [String]?,
                                authenticateWith credential: Credential?,
                                _ responseHandler: ResponseHandler?) {
        
        // Generate HTTP Basic Auth header
        var headers: HTTPHeaders?
        if let credential = credential {
            headers = [:]
            if let authorizationHeader = Request.authorizationHeader(user: credential.username, password: credential.password) {
                headers![authorizationHeader.key] = authorizationHeader.value
            }
        }
        
        // Create arguments list
        var args = ""
        if let arguments = arguments {
            for (index, arg) in arguments.enumerated() {
                
                // Start arguments list with '?'
                if index == 0 {
                    args += "?"
                }
                
                // Add argument
                args += "\(arg)"
                
                // Add separator if not the last argument
                if index != arguments.count - 1 {
                    args += "&"
                }
                
            }
        }
        
        let url = url + (tuID != nil ? "/\(tuID!)" : "") + args
        
        Alamofire.request(url, headers: headers)
            .responseJSON { (response) in
                // Log error if there is one
                if let error = response.error {
                    log.error(error)
                }
                
                // Retrieve JSON if available
                if let json = response.result.value {
                    let json = JSON(json)
                    responseHandler?(json, response.error)
                    return
                }
                
                responseHandler?(nil, response.error)
        }
    }
    
    static func download(imageURL url: URL, _ responseHandler: ((UIImage?, Error?) -> Void)?) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination).responseData { response in
            
            var image: UIImage?
            
            if let data = response.result.value {
                image = UIImage(data: data)
            }
            
            if let error = response.error {
                log.error(error)
            }
            
            responseHandler?(image, response.error)
        }
        
    }
    
}

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
        case courseRoster = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/roster"
        case getUserInfo = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/security/getUserInfo"
        case news = "https://prd-mobile.temple.edu/banner-mobileserver/rest/1.2/feed"
        case courseSearch = "https://prd-mobile.temple.edu/CourseSearch/searchCatalog.jsp"
        case marketplace = "http://tuhubapi-env.us-east-1.elasticbeanstalk.com"
        case s3 = "https://tumobilemarketplace.s3.amazonaws.com"
    }
    
    static let shared = NetworkManager()
    
    fileprivate let alamofireManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 180
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    typealias ResponseHandler = (Data?, Error?) -> Void
    
    func request(fromEndpoint endpoint: Endpoint,
                 pathParameters: [String]? = nil,
                 queryParameters: Parameters? = nil,
                 authenticateWith credential: Credential? = nil,
                 _ responseHandler: ResponseHandler?) {
        request(url: endpoint.rawValue, pathParameters: pathParameters, queryParameters: queryParameters, authenticateWith: credential, responseHandler)
    }
    
    private func request(url: String,
                         pathParameters: [String]?,
                         queryParameters: Parameters?,
                         authenticateWith credential: Credential?,
                         _ responseHandler: ResponseHandler?) {
        var url = url
        
        // Generate HTTP Basic Auth header
        var headers: HTTPHeaders?
        if let credential = credential {
            headers = [:]
            if let authorizationHeader = Request.authorizationHeader(user: credential.username, password: credential.password) {
                headers![authorizationHeader.key] = authorizationHeader.value
            }
        }
        
        if let pathParameters = pathParameters {
            for param in pathParameters {
                url += "/\(param)"
            }
        }
        
        alamofireManager.request(url, method: .get, parameters: queryParameters, encoding: URLEncoding.default, headers: headers).responseData { (response) in
            // Log error if there is one
            let error: Error? = {
                guard case let .failure(error) = response.result else { return nil }
                log.error(error)
                return error
            }()
            
            let data = response.result.value
            
            responseHandler?(data, error)
        }
        
    }
    
    func download(imageURL url: String, _ responseHandler: ((UIImage?, Error?) -> Void)?) {
        
        guard let url = URL(string: url) else { return }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        alamofireManager.download(url, to: destination).responseData { response in
            
            var image: UIImage?
            let error: Error? = {
                guard case let .failure(error) = response.result else { return nil }
                log.error(error)
                return error
            }()
            
            if let data = response.result.value {
                image = UIImage(data: data)
            }
            
            responseHandler?(image, error)
        }
        
    }
    
    func cancelAllRequests(for endpoint: Endpoint) {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            for task in tasks {
                if let url = task.currentRequest?.url, url.absoluteString.hasPrefix(endpoint.rawValue) {
                    task.cancel()
                }
            }
        }
    }
    
}

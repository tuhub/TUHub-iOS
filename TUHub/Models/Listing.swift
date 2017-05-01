//
//  Listing.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Alamofire
import SwiftyJSON
import AEXML

private let s3DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "yyyyMMdd'T'hhmmss'Z'"
    return dateFormatter
}()

class Listing {
    
    enum Kind: String {
        case product = "Product", job = "Job", personal = "Personal"
        
        static let all: [Kind] = [.product, .job, .personal]
    }
    
    var id: String!
    var title: String
    var description: String?
    var datePosted: Date!
    var ownerID: String
    var isActive: Bool
    var photosDirectory: String?
    var imageURLs: [String]?
    var owner: MarketplaceUser?
    
    required init?(json: JSON) {
        guard
            let title = json["title"].string,
            let description = json["description"].string,
            let datePosted = json["datePosted"].dateTime,
            let ownerID = json["ownerId"].string,
            let isActive = json["isActive"].string
            else {
                log.error("Unable to parse Listing")
                return nil
        }
        
        self.title = title
        self.description = description
        self.datePosted = datePosted
        self.ownerID = ownerID
        self.isActive = isActive == "true"
        
        if let photosDirectory = json["picFolder"].string, photosDirectory.characters.count > 0 {
            self.photosDirectory = photosDirectory
            
        }
    }
    
    init(title: String, desc: String?, ownerID: String, photosDir: String?) {
        self.title = title
        self.description = desc
        self.ownerID = ownerID
        self.photosDirectory = photosDir
        self.isActive = true
    }
    
    
    @discardableResult func retrievePhotoPaths(_ responseHandler: @escaping ([String]?, Error?) -> Void) -> DataRequest? {
        guard let photosDirectory = photosDirectory else { return nil }
        
        let prefix = "\(photosDirectory)/"
        let params: [String : Any] = ["list-type" : 2,
                                      "x-amz-date" : s3DateFormatter.string(from: Date()),
                                      "prefix" : prefix]
        let bucketURL = NetworkManager.Endpoint.s3.rawValue
        
        return Alamofire.request(bucketURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseData { (data) in
            var filePaths: [String]?
            guard let xmlData = data.result.value else { return }
            defer { responseHandler(filePaths, data.error) }
            do {
                let xmlDoc = try AEXMLDocument(xml: xmlData)
                let contentsXML = xmlDoc.root.children.filter({ $0.name == "Contents" && $0["Key"].string != prefix })
                
                for item in contentsXML {
                    if filePaths == nil {
                        filePaths = []
                    }
                    filePaths!.append("\(bucketURL)/\(item["Key"].string)")
                }
                self.imageURLs = filePaths
            } catch {
                log.error("Unable to parse XML. Error: \(error.localizedDescription)")
            }
        }
    }
    
    func retrieveOwner( _ responseHandler: @escaping (MarketplaceUser?, Error?)->Void) {
        MarketplaceUser.retrieve(user: ownerID) { (user, error) in
            defer { responseHandler(user, error) }
            if let error = error {
                log.error(error)
            } else if let user = user {
                self.owner = user
            }
        }
    }
    
    func post(_ responseHandler: @escaping (Listing?, Error?) -> Void) {
        fatalError("Function not implemented in Listing supertype")
    }
    
    func update(_ responseHandler: @escaping (_ error: Error?) -> Void) {
        fatalError("Function not implemented in Listing supertype")
    }
    
    class func upload(images: [UIImage], toFolder folderName: String, _ responseHandler: @escaping (Error?) -> Void) {
        
        guard images.count > 0 else { responseHandler(nil); return }
        
        let dispatchGroup = DispatchGroup()
        var error: Error?
        
        for (i, image) in images.enumerated() {
            if let data = UIImageJPEGRepresentation(image, 0.3), let url = URL(string: "\(NetworkManager.Endpoint.s3.rawValue)/\(folderName)/\(i).jpeg") {
                
                dispatchGroup.enter()
                Alamofire.upload(data, to: url, method: .put, headers: ["Content-Type" : "image/jpeg"]).response { (response) in
                    if let e = response.error {
                        error = e
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { 
            responseHandler(error)
        }
        
    }
    
}

extension Listing: Hashable {
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    var hashValue: Int {
        return id.hash
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: Listing, rhs: Listing) -> Bool {
        return lhs.id == rhs.id
    }
    
}

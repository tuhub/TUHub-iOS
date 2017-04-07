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
    dateFormatter.dateFormat = "YYYYMMDD'T'HHMMSS'Z'"
    return dateFormatter
}()

class Listing {
    
    enum Kind: String {
        case product = "Product", job = "Job", personal = "Personal"
        
        static let all: [Kind] = [.product, .job, .personal]
    }
    
    internal(set) var id: String!
    fileprivate(set) var title: String
    fileprivate(set) var description: String
    fileprivate(set) var datePosted: Date
    fileprivate(set) var ownerID: String
    fileprivate(set) var isActive: Bool
    fileprivate(set) var photoPaths: [String]?
    fileprivate(set) var owner: MarketplaceUser?
    fileprivate var photosDirectory: String?
    fileprivate var thumbnail: UIImage?
    
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
        
        if let photosDirectory = json["picFolder"].string {
            self.photosDirectory = photosDirectory
            
        }
    }
    
    func retrievePhotoPaths(_ responseHandler: @escaping ([String]?, Error?) -> Void) {
        guard let photosDirectory = photosDirectory else { return }
        
        let prefix = "\(photosDirectory)/"
        let params: [String : Any] = ["list-type" : 2,
                                      "x-amz-date" : s3DateFormatter.string(from: Date()),
                                      "prefix" : prefix]
        
        Alamofire.request("https://tumobilemarketplace.s3.amazonaws.com", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseData { (data) in
            var filePaths: [String]?
            guard let xmlData = data.result.value else { return }
            defer { responseHandler(filePaths, data.error) }
            do {
                let xmlDoc = try AEXMLDocument(xml: xmlData)
                let contentsXML = xmlDoc.root.children.filter({ $0.name == "Contents" && $0["Key"].string != prefix })
                
                filePaths = []
                for item in contentsXML {
                    filePaths!.append(item["Key"].string)
                }
                self.photoPaths = filePaths
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
    
    func retrieveThumbnail(_ responseHandler: @escaping (UIImage?, Error?) -> Void) {
        retrievePhotoPaths { (paths, error) in
            if let path = paths?.first {
                NetworkManager.shared.download(imageURL: "https://tumobilemarketplace.s3.amazonaws.com/\(path)") { (image, error) in
                    self.thumbnail = image
                    if let error = error {
                        log.error("Unable to retrieve thumbanil. Error: \(error)")
                    }
                    responseHandler(image, error)
                }
            } else {
                responseHandler(nil, error)
            }
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

//
//  NewsItem.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

class NewsItem {
    
    enum Feed: String {
        case all = "feed1357134273663,feed1358196258785,feed1358197717016,feed1360620171888,feed1362405229000,feed1362406369942,feed1362405688434,feed1362405586009,feed1383143213597,feed1383143223191,feed1383143236812,feed1383143243155,feed1383143253860,feed1383143263909,feed1383143274415,feed1383143285101,feed1383143312318,feed1383143507786"
    }
    
    let entryID: String
    let feedName: String
    let date: Date
    let url: URL
    let title: String
    let description: String
    let contentHTML: String
    fileprivate let imageURL: URL?
    fileprivate(set) var image: UIImage?
    fileprivate(set) var isDownloadingImage = false
    
    init?(json: JSON) {
        guard
            let entryID = json["entryId"].string,
            let feedName = json["feedName"].string,
            let date = json["postDate"].dateTime,
            let url = json["link"].array?.first?.url,
            let title = json["title"].string,
            let contentHTML = json["content"].string,
            let imageURL = json["logo"].url
            
            else {
                log.error("Error: Unable to parse NewsItem.")
                return nil
        }
        
        self.entryID = entryID
        self.feedName = feedName
        self.date = date
        self.url = url
        self.title = title
        self.contentHTML = contentHTML
        self.imageURL = imageURL
        
        // To get the subtitle of the NewsItem
        // This returns an array which we can use to get news, we can loop through array starting from index 1 to get all the text
        if let firstLine = contentHTML.components(separatedBy: "\n").first {
            // This get rids of almost all HTML tags
            var formatedText = firstLine.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            
            // This deletes "Subtitle:&nbsp;" which is in front of the subtitle/news description
            formatedText = formatedText.replacingOccurrences(of: "Subtitle:&nbsp;", with: "", options: .regularExpression, range: nil)
            
            self.description = formatedText
            return
        }
        
        return nil
    }
    
    func downloadImage(_ responseHandler: ((String, UIImage?, Error?) -> Void)?) {
        
        guard let imageURL = imageURL else {
            log.info("Attempting to download an image for a NewsItem that does not have an image URL associated with it.")
            return
        }
        
        isDownloadingImage = true
        // Attempt to download the associated image
        NetworkManager.download(imageURL: imageURL) { (image, error) in
            self.isDownloadingImage = false
            self.image = image
            responseHandler?(self.entryID, image, error)
        }
        
    }
    
}

extension NewsItem {
    
    typealias NewsItemResponseHandler = ([NewsItem]?, Error?) -> Void
    
    static func retrieve(fromFeeds feeds: [Feed], _ responseHandler: NewsItemResponseHandler?) {
        
        // Don't waste time doing networking if no feeds are selected
        guard feeds.count > 0 else {
            responseHandler?(nil, nil)
            return
        }
        
        // Generate argument based on feeds selected
        var arg = "namekeys="
        for (count, feed) in feeds.enumerated() {
            arg.append(feed.rawValue)
            if count < feeds.count - 1 {
                arg.append(",")
            }
        }
        
        NetworkManager.request(fromEndpoint: .news, arguments: [arg]) { (json, error) in
            
            var newsItems: [NewsItem]?
            
            if let error = error {
                log.error(error)
            }
            
            if let entries = json?["entries"].array {
                for subJSON in entries {
                    
                    // Initialize if first element
                    if newsItems == nil {
                        newsItems = [NewsItem]()
                    }
                    
                    // Append parsed item
                    if let newsItem = NewsItem(json: subJSON) {
                        newsItems!.append(newsItem)
                    }
                }
                
            }
            
            responseHandler?(newsItems, error)
            
        }
    }
    
}

//
//  NewsItem.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

class NewsItem {
    
    let entryID: String
    let feedName: String
    let date: Date
    let url: URL
    let title: String
    let description: String
    let contentHTML: String
    var content: NSAttributedString?
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
            arg.append(feed.namekey)
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

extension NewsItem {
    
    /// Asynchronously parses a string containing HTML into an NSAttributed string matching the label's designated style
    func parseContent(_ completionHandler: (()->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to parse HTML to NSAttributedString
            do {
                let fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
                let modifiedFont = NSString(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize)\">%@</span>" as NSString, self.contentHTML) as String
                
                //process collection values
                let attrStr = try NSAttributedString(
                    data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
                    options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
                    documentAttributes: nil)
                
                debugPrint(attrStr)
                DispatchQueue.main.async {
                    self.content = attrStr
                    completionHandler?()
                }
                
            } catch {
                log.error("Error: Unable to parse HTML to NSAttributedString.")
                completionHandler?()
            }
        }
    }
    
}

extension NewsItem {
    
    enum Feed {
        case arts,
        athletics,
        campus,
        community,
        global,
        research,
        staff,
        students,
        sustainability,
        twentyTwenty

        // These feeds don't play well with our parser... maybe add later?
//        labs,
//        system
        
        static var allValues: [Feed] {
            var all: [Feed] = [arts,
                               athletics,
                               campus,
                               community,
                               global,
                               research,
                               staff,
                               students,
                               sustainability,
                               twentyTwenty]
            
            all.sort { return $0.name < $1.name }
            return all
        }
        
        static var allNames: [String] {
            var names = [String]()
            for feed in allValues {
                names.append(feed.name)
            }
            names.sort()
            return names
        }
        
        var name: String {
            
            switch self {
            case .arts:
                return "Arts & Culture"
            case .athletics:
                return "Athletics"
            case .campus:
                return "Campus News"
            case .community:
                return "Community Engagement"
            case .global:
                return "Global Temple"
            case.research:
                return "Research"
            case .staff:
                return "Staff & Faculty"
            case .students:
                return "Student Success"
            case .sustainability:
                return "Sustainability"
            case .twentyTwenty:
                return "Temple 20/20"
//            case .labs:
//                return "Computer Labs"
//            case .system:
//                return "System Status"
            }
            
        }
        
        var namekey: String {
            switch self {
            case .arts:
                return "feed1383143213597"
            case .athletics:
                return "feed1383143223191"
            case .campus:
                return "feed1383143236812"
            case .community:
                return "feed1383143243155"
            case .global:
                return "feed1383143253860"
            case.research:
                return "feed1383143263909"
            case .staff:
                return "feed1383143274415"
            case .students:
                return "feed1383143285101"
            case .sustainability:
                return "feed1383143312318"
            case .twentyTwenty:
                return "feed1383143507786"
//            case .labs:
//                return "feed1416259989888"
//            case .system:
//                return "feed1416259888303"
            }
        }
    }
    
}

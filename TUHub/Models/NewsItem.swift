//
//  NewsItem.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON
import Kanna
import AlamofireImage

class NewsItem {
    
    private static let maxDescriptionLength = 100
    private static let templeNewsURL = "http://news.temple.edu"
    
    let entryID: String
    let feedName: String
    let date: Date
    let url: URL
    let title: String
    private(set) var subtitle: String?
    private(set) var description: String?
    let contentHTML: String
    var content: NSAttributedString?
    private(set) var imageURLs: [URL]
    
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
        self.imageURLs = [imageURL]
    
        
        // Parse the HTML to retrieve and remove subtitle and date
        guard let doc = Kanna.HTML(html: contentHTML, encoding: .utf8), let bodyNode = doc.body else { return nil }
        
        // Attempt to find the subtitle node and set the subtitle to its contents
        if let subtitleNode = bodyNode.at_xpath("//div[@class='field field-name-field-subtitle field-type-text-long field-label-above']"), let text = subtitleNode.at_xpath("//div[@class='field-items']")?.text {
            self.subtitle = text.replacingOccurrences(of: "\n", with: "")
            
            // Remove the subtitle from the HTML
            bodyNode.removeChild(subtitleNode)
        }
        
        // Attempt to find the article abstract node and set the abstract to its contents
        if let abstract = bodyNode.at_xpath("//div[@class='field field-name-field-abstract field-type-text-long field-label-hidden']") {
            self.description = abstract.text
            
            // Remove abstract from the HTML
            bodyNode.removeChild(abstract)
        }
        // If unavailable, attempt to set description to the first line or 100 chars of text
        else if let text = bodyNode.text {
            self.description = NewsItem.getFirstLine(of: text)
        }
        
        // Remove the date node if present
        if let dateNode = bodyNode.at_xpath("//div[@class='field field-name-field-news-date field-type-date field-label-hidden']") {
            bodyNode.removeChild(dateNode)
        }
        
        let imageNodes = bodyNode.css("img")
        for imageNode in imageNodes {
            if let src = imageNode["src"], let url = URL(string: NewsItem.templeNewsURL + src) {
                imageURLs.append(url)
            }
        }
        
        self.contentHTML = bodyNode.toHTML!
        
    }
    
    private static func getFirstLine(of text: String) -> String {
        if let index = text.characters.index(of: "\n") {
            
            // Get the position of this character, substract 1 to not add the \n to the title
            let dist = text.distance(from: text.startIndex, to: index).advanced(by: -1)
            let index = text.index(text.startIndex, offsetBy: dist)
            
            return text.substring(to: index)
        } else {
            
            // If it's longer than max length, only get max length
            if text.characters.count >= NewsItem.maxDescriptionLength {
                let index = text.index(text.startIndex, offsetBy: NewsItem.maxDescriptionLength)
                return text.substring(to: index)
            }
                
            // If it's shorter, count the chars and get up to the last of this line
            else{
                return text
            }
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
        
        var feedsString = ""
        for (count, feed) in feeds.enumerated() {
            feedsString.append(feed.namekey)
            if count < feeds.count - 1 {
                feedsString.append(",")
            }
        }
        
        let params: [String : Any] = ["namekeys" : feedsString]
        
        NetworkManager.shared.request(fromEndpoint: .news, parameters: params) { (data, error) in
            
            var newsItems: [NewsItem]?
            
            defer { responseHandler?(newsItems, error) }
            guard let data = data else { return }
            let json = JSON(data)
            
            if let entries = json["entries"].array {
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
            
            if let error = error {
                log.error(error)
            }
            
        }
    }
    
}

extension NewsItem {
    
    /// Asynchronously parses a string containing HTML into an NSAttributed string matching the label's designated style
    func parseContent(_ completionHandler: ((NSAttributedString?)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to parse HTML to NSAttributedString
            do {
                let fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
                let modifiedFont = NSString(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize)\">%@</span>" as NSString, self.contentHTML) as String
                
                //process collection values
                let attrStr = try NSAttributedString(
                    data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
                    options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                              NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
                    documentAttributes: nil)
                
                DispatchQueue.main.async {
                    self.content = attrStr
                    completionHandler?(attrStr)
                }
                
            } catch {
                log.error("Error: Unable to parse HTML to NSAttributedString.")
                completionHandler?(nil)
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

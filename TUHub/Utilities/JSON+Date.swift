//
//  JSON+Date.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

extension JSON {
    
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.dateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    public var dateTime: Date? {
        get {
            if let str = self.string {
                return JSON.dateTimeFormatter.date(from: str)
            }
            return nil
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
    
    private static let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
}

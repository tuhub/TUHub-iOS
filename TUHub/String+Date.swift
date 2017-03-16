//
//  String+Date.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation

extension String {
    
    public var date: Date? {
        return String.dateFormatter.date(from: self)
    }
    
    public var dateTime: Date? {
        return String.dateTimeFormatter.date(from: self)
    }
    
    public func dateTime(timezone: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ"
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        let date = dateFormatter.date(from: self)
        return date
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
    
    private static let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
    
}

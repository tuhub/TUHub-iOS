//
//  Date+String.swift
//  TUHub
//
//  Created by Connor Crawford on 3/9/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation

extension Date {
    
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var datetime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var age: String {
        let date = self
        let calendar = Calendar.current
        
        // Determine minutes and hours since date
        let components = calendar.dateComponents([.minute, .hour, .day, .month, .year], from: date, to: Date())
        if components.year == 0 {
            if components.month == 0 {
                if components.day == 0 {
                    if components.hour == 0 {
                        // Print minutes if less than an hour
                        return "\(components.minute!) min ago"
                    } else {
                        // Print hours if less than a day
                        return "\(components.hour!) hr ago"
                    }
                } else {
                    // Print days if less than a month
                    return "\(components.day!) day ago"
                }
            } else {
                // Print months if less than a year
                return "\(components.month!) mon ago"
            }
        }
        // Print years if greater than 0
        return "\(components.year!) yr ago"
    }
    
}

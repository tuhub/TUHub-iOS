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
        
        func addSIfNeeded(_ unit: Int) -> String {
            return unit > 1 ? "s" : ""
        }
        
        // Determine minutes and hours since date
        let components = calendar.dateComponents([.minute, .hour, .day, .month, .year], from: date, to: Date())
        if components.year == 0 {
            if components.month == 0 {
                if components.day == 0 {
                    if components.hour == 0 {
                        // Print minutes if less than an hour
                        let minutes = components.minute!
                        return "\(minutes) minute" + addSIfNeeded(minutes) + " ago"
                    } else {
                        // Print hours if less than a day
                        let hours = components.hour!
                        return "\(hours) hour" + addSIfNeeded(hours) + " ago"
                    }
                } else {
                    // Print days if less than a month
                    let days = components.day!
                    return "\(days) day" + addSIfNeeded(days) + " ago"
                }
            } else {
                // Print months if less than a year
                let months = components.month!
                return "\(months) month" + addSIfNeeded(months) + " ago"
            }
        }
        // Print years if greater than 0
        let years = components.year!
        return "\(years) year" + addSIfNeeded(years) + " ago"
    }
    
}

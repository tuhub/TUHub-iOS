//
//  Time.swift
//  TUHub
//
//  Created by Connor Crawford on 4/22/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Foundation

struct Time: Comparable, Equatable {

    var hour: Int
    var minute: Int
    var second: Int
    
    init?(_ dateComponents: DateComponents) {
        guard let hour = dateComponents.hour,
            let minute = dateComponents.minute,
            let second = dateComponents.second
            else {
                return nil
        }
        self.hour = hour
        self.minute = minute
        self.second = second
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func <(lhs: Time, rhs: Time) -> Bool {
        if lhs.hour != rhs.hour {
            return lhs.hour < rhs.hour
        }
        if lhs.minute != rhs.minute {
            return lhs.minute < rhs.minute
        }
        return lhs.second < rhs.second
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
    }

}

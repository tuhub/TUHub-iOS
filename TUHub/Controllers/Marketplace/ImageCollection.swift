//
//  ImageURLCollection.swift
//  TUHub
//
//  Created by Connor Crawford on 4/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

public struct ImageCollection: Equatable {
    
    lazy var images = [UIImage]()
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static public func ==(lhs: ImageCollection, rhs: ImageCollection) -> Bool {
        var lhs = lhs
        var rhs = rhs
        guard lhs.images.count == rhs.images.count else { return false }
        
        for i in 0 ..< lhs.images.count {
            if lhs.images[i] != rhs.images[i] {
                return false
            }
        }
        return true
    }
}

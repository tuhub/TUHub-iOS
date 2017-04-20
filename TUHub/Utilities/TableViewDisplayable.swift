//
//  TableViewDisplayable.swift
//  TUHub
//
//  Created by Connor Crawford on 4/19/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

protocol TableViewDisplayable {
    typealias TableViewAttributes = (key: String, identifier: String)
    
    var tableViewAttributes: [TableViewAttributes] { get }
}

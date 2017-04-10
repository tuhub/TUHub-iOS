//
//  CourseDetailTableViewControllerCellType.swift
//  TUHub
//
//  Created by Connor Crawford on 4/5/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

enum CourseDetailTableViewControllerCellType: String {
    case headerCell = "headerCell"
    case titleCell = "titleCell"
    case basicCell = "basicCell"
    case rightDetailCell = "rightDetailCell"
    case subtitleCell = "subtitleCell"
}

extension UITableView {
    func dequeueReusableCell(withType type: CourseDetailTableViewControllerCellType, for indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: type.rawValue, for: indexPath)
    }
}

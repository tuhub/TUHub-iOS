//
//  UIColor.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var cherry: UIColor {
        return UIColor(colorLiteralRed: 158.0/256, green: 27.0/256, blue: 52.0/256, alpha: 1.0)
    }
    
    static let allColors: [UIColor] = {
        return [UIColor.cyan,
                UIColor.yellow,
                UIColor.magenta,
                UIColor.red,
                UIColor.green,
                UIColor.blue,
                UIColor.orange,
                UIColor.purple]
    }()
}

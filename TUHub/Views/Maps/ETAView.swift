//
//  ETAView.swift
//  TUHub
//
//  Created by Connor Crawford on 4/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class ETAView: UIView {
    @IBOutlet weak var transportMethodImageView: UIImageView!
    @IBOutlet weak var estimateLabel: UILabel!
    
    class func instanceFromNib() -> ETAView {
        return UINib(nibName: String(describing: ETAView.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ETAView
    }
}

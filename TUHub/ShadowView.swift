//
//  ShadowView.swift
//  TUHub
//
//  Created by Connor Crawford on 3/15/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        layer.shadowOpacity = 0.2
        layer.shadowPath = shadowPath.cgPath
    }

}

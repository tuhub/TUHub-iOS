//
//  MapsImageTableViewCell.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI

class MapsImageTableViewCell: UITableViewCell {
    
    // IBOutlets
    
    @IBOutlet weak var businessImageView: UIImageView!
    
    func setUp(from selectedBusiness: YLPBusiness) {
        
        if  selectedBusiness.imageURL != nil {
            let url = URL(string: "\(selectedBusiness.imageURL!)")
            businessImageView.af_setImage(withURL: url!)
        }
    }

}

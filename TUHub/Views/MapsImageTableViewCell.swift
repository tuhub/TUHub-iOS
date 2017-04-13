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
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    func setUp(from selectedBusiness: YLPBusiness) {
        
        if  selectedBusiness.imageURL != nil {
            let url = URL(string: "\(selectedBusiness.imageURL!)")
            businessImageView.af_setImage(withURL: url!)
        }
        
        addressLabel.text = selectedBusiness.location.address[0]
        stateLabel.text = "\(selectedBusiness.location.city), \(selectedBusiness.location.stateCode) \(selectedBusiness.location.postalCode)"
        
    }

}

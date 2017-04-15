//
//  MapsBuildingImageTableViewCell.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/15/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI

class MapsBuildingImageTableViewCell: UITableViewCell {
    
    // IBOutlets
    @IBOutlet weak var buildingImageView: UIImageView!
    
    
    func setUp(from selectedBuilding: Building) {
        
        if  selectedBuilding.imageURL != nil {
            let url = URL(string: "\(selectedBuilding.imageURL!)")
            buildingImageView.af_setImage(withURL: url!)
        }
    }
    
}

//
//  MapsHeaderTableViewCell.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI
import Cosmos

class MapsHeaderTableViewCell: UITableViewCell {
    
    // IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingCosmosView: CosmosView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    func setUp(from selectedBusiness: YLPBusiness) {
        titleLabel.text = selectedBusiness.title
        var text  = ""
        for (i, category) in selectedBusiness.categories.enumerated() {
            text += category.name
            if i < selectedBusiness.categories.count - 1 {
                text += ", "
            }
            categoryLabel.text = text
        }
        
        // Rating Stars
        ratingCosmosView.rating = selectedBusiness.rating
        ratingCosmosView.settings.fillMode = .precise
        ratingCosmosView.text = "(\(selectedBusiness.reviewCount)) on Yelp"
        
    }
    
}

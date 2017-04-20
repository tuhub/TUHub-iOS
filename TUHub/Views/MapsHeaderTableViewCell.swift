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
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    func setUp(with location: Location) {
        titleLabel.text = location.title!
        var text  = ""
        
        if let business = location as? YLPBusiness {
            for (i, category) in business.categories.enumerated() {
                text += category.name
                if i < business.categories.count - 1 {
                    text += ", "
                }
                categoryLabel.text = text
            }
            
            // Rating Stars
            ratingView.rating = business.rating
            ratingView.settings.fillMode = .precise
            ratingView.text = "(\(business.reviewCount)) on Yelp"
        } else {
            ratingView.removeFromSuperview()
            categoryLabel.removeFromSuperview()
        }
    }
    
}

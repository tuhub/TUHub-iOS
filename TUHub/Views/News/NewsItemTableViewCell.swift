//
//  NewsItemTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import AlamofireImage

class NewsItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    func setUp(from newsItem: NewsItem) {
        titleLabel.text = newsItem.title
        descriptionLabel.text = newsItem.description
        ageLabel.text = newsItem.date.age
        
        // Asynchronously set image with a filter to downsize it 
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(size: thumbnailImageView.frame.size, radius: 4)
        thumbnailImageView.af_setImage(withURL: newsItem.imageURLs.first!,
                                       placeholderImage: nil,
                                       filter: filter)
    }

}

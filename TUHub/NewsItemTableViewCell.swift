//
//  NewsItemTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class NewsItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    func setUp(from newsItem: NewsItem) {
        titleLabel.text = newsItem.title
        descriptionLabel.text = newsItem.description
        thumbnailImageView.image = newsItem.image
//        ageLabel = newsItem.date.timeIntervalSinceNow //TODO: Figure out elapsed time
    }

}

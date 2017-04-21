//
//  NewsHeaderTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class NewsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var hairlineHeight: NSLayoutConstraint!
    
    func setUp(from newsItem: NewsItem) {
        titleLabel.text = newsItem.title
        subtitleLabel.text = newsItem.subtitle
        detailLabel.text = newsItem.date.datetime
        hairlineHeight.constant = 1 / UIScreen.main.scale
    }
    
}

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
    @IBOutlet weak var detailLabel: UILabel!
    
    func setUp(from newsItem: NewsItem) {
        titleLabel.text = newsItem.title
        //detailLabel.text = newsItem.date.timeIntervalSinceNow // TODO: Figure out how to do this
    }
    
}

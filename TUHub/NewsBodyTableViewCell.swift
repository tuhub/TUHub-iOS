//
//  NewsBodyTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class NewsBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func setUp(with newsItem: NewsItem, from tableView: UITableView) {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        newsItem.parseContent() { text in
            self.activityIndicator.stopAnimating()
            self.contentTextView.attributedText = text
            tableView.beginUpdates()
            tableView.endUpdates()
            self.contentTextView.isHidden = false
        }
    }
    
}

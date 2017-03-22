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
        
        separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        
        if let text = newsItem.content {
            self.contentTextView.attributedText = text
            self.contentTextView.isHidden = false
        } else {
            activityIndicator.startAnimating()
            newsItem.parseContent() { text in
                self.activityIndicator.stopAnimating()
                if let indexPath = tableView.indexPath(for: self) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
    }
    
}

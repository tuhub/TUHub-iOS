//
//  NewsBodyTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class NewsBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImageView: ScaleAspectFitImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    func setUp(from newsItem: NewsItem) {
        if let image = newsItem.image {
            newsImageView.image = image
        } else {
//            newsItem.downloadImage({ (_, image, error) in
//                DispatchQueue.main.async {
//                    self.newsImageView.image
//                }
//            })
        }
        
        contentLabel.setAttrbitedText(fromHTMLString: newsItem.contentHTML)
    }
    
}

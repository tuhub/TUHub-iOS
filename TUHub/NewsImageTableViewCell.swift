//
//  NewsImageTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 3/16/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class NewsImageTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    weak var tableView: UITableView?
    
    func updateImageView(with image: UIImage?) {
        if let imageWidth = image?.size.width, let imageHeight = image?.size.height {
            let imageViewWidth = newsImageView.bounds.width
            imageHeightConstraint.constant = imageHeight * imageViewWidth / imageWidth
            newsImageView.image = image
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }   
    }

}

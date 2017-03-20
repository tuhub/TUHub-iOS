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
    
    weak var tableView: UITableView?
    
    func updateImageView(with image: UIImage?) {
        tableView?.beginUpdates()
        newsImageView.image = image
        tableView?.endUpdates()
    }

}

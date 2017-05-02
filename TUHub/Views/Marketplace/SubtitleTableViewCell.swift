//
//  SubtitleTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subtitleTextView.textContainerInset = UIEdgeInsets.zero
        subtitleTextView.textContainer.lineFragmentPadding = 0
    }
}

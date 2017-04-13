//
//  BusinessTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Cosmos

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

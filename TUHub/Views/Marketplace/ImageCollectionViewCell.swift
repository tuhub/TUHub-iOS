//
//  ImageCollectionViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/7/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

}

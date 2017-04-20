//
//  ImageGalleryCollectionViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}

//
//  ImageGalleryTableViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import SKPhotoBrowser

protocol ImageGalleryTableViewCellDelegate {
    func didSelect(imageView: UIImageView, from images: [SKPhoto], at row: Int)
}

private let reuseID = "imageCell"

class ImageGalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var spaceBetweenCells: CGFloat = 4
    
    var delegate: ImageGalleryTableViewCellDelegate?
    fileprivate var imageURLs: [URL]! {
        didSet {
            if imageURLs != nil {
                images = Array<UIImage?>(repeating: nil, count: imageURLs.count)
            } else {
                images.removeAll(keepingCapacity: false)
            }
        }
    }
    lazy var images: [UIImage?] = {
       return Array<UIImage?>(repeating: nil, count: self.imageURLs.count)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageGalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseID)
        
        let layout = collectionView.collectionViewLayout as? CarouselFlowLayout
        layout?.spacingMode = .fixed(spacing: spaceBetweenCells)
        layout?.scrollDirection = .horizontal
    }
    
    func setUp(with imageURLs: [URL]) {
        self.imageURLs = imageURLs
    }
    
}

extension ImageGalleryTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath)
        if let cell = cell as? ImageGalleryCollectionViewCell {
            cell.imageView?.af_setImage(withURL: imageURLs[indexPath.row])
        }
        return cell
    }
    
}

extension ImageGalleryTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let imageView = (collectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.imageView {
            
            var skPhotos: [SKPhoto] = []
            for (i, image) in images.enumerated() {
                if let image = image {
                    skPhotos.append(SKPhoto.photoWithImage(image))
                } else {
                    skPhotos.append(SKPhoto.photoWithImageURL(imageURLs![i].absoluteString))
                }
            }
            
            delegate?.didSelect(imageView: imageView, from: skPhotos, at: indexPath.row)
        }
        
    }
    
}

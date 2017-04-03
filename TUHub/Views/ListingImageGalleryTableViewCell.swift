//
//  ListingImageGalleryTableViewCell.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/2/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import SKPhotoBrowser

fileprivate let listingImageCellID = "listingImageCell"

protocol MarketplaceImageGalleryTableViewCellDelegate {
    func present(_ viewController: UIViewController)
}

class ListingImageGalleryTableViewCell: UITableViewCell {
    
    private static let spaceBetweenCells: CGFloat = 8

    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var newsItem: NewsItem!
    var delegate: MarketplaceImageGalleryTableViewCellDelegate!
    
    func setUp(with newsItem: NewsItem, delegate: MarketplaceImageGalleryTableViewCellDelegate) {
        self.newsItem = newsItem
        self.delegate = delegate
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        let layout = imageCollectionView.collectionViewLayout as? CarouselFlowLayout
        layout?.spacingMode = .fixed(spacing: ListingImageGalleryTableViewCell.spaceBetweenCells)
        layout?.scrollDirection = .horizontal
    }
}

extension ListingImageGalleryTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsItem.imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listingImageCellID, for: indexPath)
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
            imageView.af_setImage(withURL: newsItem.imageURLs[indexPath.row])
        }
        return cell
    }
    
}

extension ListingImageGalleryTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath),
            let imageView = cell.contentView.viewWithTag(1) as? UIImageView,
            let image = imageView.image {
            
            let skPhotos = newsItem.imageURLs.map { SKPhoto.photoWithImageURL($0.absoluteString) }
            let browser = SKPhotoBrowser(originImage: image, photos: skPhotos, animatedFromView: imageView)
            browser.initializePageIndex(indexPath.row)
            delegate.present(browser)
        }
        
    }
    
}


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
    
    var listing: Listing!
    var delegate: MarketplaceImageGalleryTableViewCellDelegate!
    
    func setUp(with listing: Listing, delegate: MarketplaceImageGalleryTableViewCellDelegate) {
        self.listing = listing
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
        return listing.photoPaths?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listingImageCellID, for: indexPath)
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView, let url = URL(string: "\(NetworkManager.Endpoint.s3.rawValue)/\(listing.photoPaths![indexPath.row])") {
            imageView.af_setImage(withURL: url)
        }
        return cell
    }
    
}

extension ListingImageGalleryTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath),
            let imageView = cell.contentView.viewWithTag(1) as? UIImageView,
            let image = imageView.image {
            
            if let skPhotos: [SKPhoto] = listing.photoPaths?.flatMap({ SKPhoto.photoWithImageURL("\(NetworkManager.Endpoint.s3.rawValue)/\($0)") }) {
                let browser = SKPhotoBrowser(originImage: image, photos: skPhotos, animatedFromView: imageView)
                browser.initializePageIndex(indexPath.row)
                delegate.present(browser)
            }
        }
        
    }
    
}


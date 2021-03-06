//
//  ListingCollectionViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

protocol ListingCollectionViewCellDelegate {
    func cell(_ cell: ListingCollectionViewCell, didLoadImage image: UIImage?)
}

class ListingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurryDetailsView: BlurryListingDetailView!
    @IBOutlet weak var detailsView: ListingDetailView!
    
    var delegate: ListingCollectionViewCellDelegate!
    var photoPathsRequest: DataRequest?
    
    override var intrinsicContentSize: CGSize {
        return imageView.image?.size ?? super.intrinsicContentSize
    }
    
    func setUp(_ listing: Listing, _ delegate: ListingCollectionViewCellDelegate) {
        
        self.delegate = delegate
        
        // Hide all views
        imageView.isHidden = true
        detailsView.isHidden = true
        blurryDetailsView.isHidden = true
        
        
        if let imageURLs = listing.imageURLs {
            if imageURLs.count > 0 {
                setUpBlurryDetailsView(listing)
            } else {
                setUpDetailsView(listing)
            }
        } else {
            photoPathsRequest = listing.retrievePhotoPaths { (paths, error) in
                if paths != nil {
                    self.setUpBlurryDetailsView(listing)
                } else {
                    self.setUpDetailsView(listing)
                }
            }
        }
    }
    
    func setUpBlurryDetailsView(_ listing: Listing) {
        
        guard let imageURL = listing.imageURLs?.first else {
            setUpDetailsView(listing)
            return
        }
        
        // Show/hide views
        imageView.isHidden = false
        detailsView.isHidden = true
        blurryDetailsView.isHidden = false
        
        blurryDetailsView.textLabel.text = listing.title
        if let product = listing as? Product {
            blurryDetailsView.detailTextLabel.text = product.price
        } else {
            blurryDetailsView.detailTextLabel.text = nil
        }
        
        if let url = URL(string: imageURL) {
            imageView.af_setImage(withURL: url) { (response) in
                if let error = response.error {
                    dump(error)
                }
                if let image = response.value {
                    self.delegate.cell(self, didLoadImage: image)
                } else {
                    self.setUpDetailsView(listing)
                }
                
            }
        }

    }
    
    func setUpDetailsView(_ listing: Listing) {
        // Show/hide views
        self.imageView.isHidden = true
        self.detailsView.isHidden = false
        self.blurryDetailsView.isHidden = true
        
        self.detailsView.textLabel.text = listing.title
        if let product = listing as? Product {
            self.detailsView.detailTextLabel.text = product.price
        } else {
            self.detailsView.detailTextLabel.text = nil
        }
        
        // Tell the delegate that there's no image in this cell so it can be resized appropriately
        self.delegate.cell(self, didLoadImage: nil)
    }
    
    override func prepareForReuse() {
        imageView.af_cancelImageRequest()
        if let request = photoPathsRequest {
            request.cancel()
            self.photoPathsRequest = nil
        }
        
        imageView.image = nil
        blurryDetailsView.textLabel.text = nil
        blurryDetailsView.detailTextLabel.text = nil
        detailsView.textLabel.text = nil
        detailsView.detailTextLabel.text = nil
        imageView.isHidden = true
        detailsView.isHidden = true
        blurryDetailsView.isHidden = true
        super.prepareForReuse()
    }
    
}


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

protocol ImageLoadedDelegate {
    func didLoad(image: UIImage?, at indexPath: IndexPath)
}

class ListingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurryDetailsView: BlurryListingDetailView!
    @IBOutlet weak var detailsView: ListingDetailView!
    
    var delegate: ImageLoadedDelegate!
    var indexPath: IndexPath!
    var photoPathsRequest: DataRequest?
    
    func setUp(_ listing: Listing, _ delegate: ImageLoadedDelegate, _ indexPath: IndexPath) {
        
        self.delegate = delegate
        self.indexPath = indexPath
        
        // Hide all views
        imageView.isHidden = true
        detailsView.isHidden = true
        blurryDetailsView.isHidden = true
        
        if let _ = listing.imageURLs?.first {
            setUpBlurryDetailsView(listing)
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
                    return
                }
                if let image = response.value {
                    self.delegate.didLoad(image: image, at: self.indexPath)
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


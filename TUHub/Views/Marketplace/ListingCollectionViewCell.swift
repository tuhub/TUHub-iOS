//
//  ListingCollectionViewCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/3/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
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
    
    func setUp(_ listing: Listing, _ delegate: ImageLoadedDelegate, _ indexPath: IndexPath) {
        
        self.delegate = delegate
        self.indexPath = indexPath
        
        // Hide all views
        imageView.isHidden = true
        detailsView.isHidden = true
        blurryDetailsView.isHidden = true
        
        if let _ = listing.photoPaths?.first {
            setUpBlurryDetailsView(listing)
        } else {
            listing.retrievePhotoPaths { (paths, error) in
                if paths != nil {
                    self.setUpBlurryDetailsView(listing)
                } else {
                    self.setUpDetailsView(listing)
                }
            }
            
        }
    }
    
    func setUpBlurryDetailsView(_ listing: Listing) {
        
        guard let photoPath = listing.photoPaths?.first else {
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
        
        if let url = URL(string: "\(NetworkManager.Endpoint.s3.rawValue)/\(photoPath)") {
            imageView.af_setImage(withURL: url) { (response) in
                let image = response.value
                if image == nil {
                    self.setUpDetailsView(listing)
                }
                self.delegate.didLoad(image: image, at: self.indexPath)
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
        super.prepareForReuse()
        imageView.image = nil
    }
    
}


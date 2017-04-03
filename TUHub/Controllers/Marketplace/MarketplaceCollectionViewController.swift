//
//  MarketplaceCollectionViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/30/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import AlamofireImage

import AWSDynamoDB

private let reuseIdentifier = "marketplaceCell"

class MarketplaceCollectionViewController: UICollectionViewController {

    fileprivate var newsItems: [NewsItem]? {
        didSet {
            if let newsItems = newsItems {
                images = [UIImage?](repeating: nil, count: newsItems.count)
            } else {
                images = nil
            }
        }
    }
    fileprivate var images: [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Clear selection between presentations
         self.clearsSelectionOnViewWillAppear = true
        
        Listing.retrievePage(true) { (listings, error) in
            debugPrint(listings)
        }
        
        setupCollectionView()
    }

    //MARK: - CollectionView UI Setup
    func setupCollectionView() {
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Collection view attributes
        self.collectionView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView?.alwaysBounceVertical = true
        
        collectionView?.collectionViewLayout = layout
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: UICollectionViewDataSource
extension MarketplaceCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return newsItems == nil ? 0 : 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsItems?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView, let newsItem = newsItems?[indexPath.row] {
            imageView.af_setImage(withURL: newsItem.imageURLs.first!,
                                  placeholderImage: nil,
                                  filter: nil) { (response) in
                                    if response.value != nil && self.images?[indexPath.row] == nil {
                                        self.images?[indexPath.row] = response.result.value
                                        collectionView.collectionViewLayout.invalidateLayout()
                                    }
            }
        }
        
        return cell
    }
}

extension MarketplaceCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        
        guard let image = images?[indexPath.row]
            else { return CGSize(width: 50, height: 70) }
        return image.size
    }
}

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


// Segue Identifiers
fileprivate let listingDetailSegueID = "showListingDetail"

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
    fileprivate weak var marketplaceDetailVC: MarketplaceDetailTableViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Clear selection between presentations
         self.clearsSelectionOnViewWillAppear = true
        
        NewsItem.retrieve(fromFeeds: NewsItem.Feed.allValues) { (items, error) in
            self.newsItems = items
            self.collectionView?.reloadData()
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
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case listingDetailSegueID:
            
            guard let cell = sender as? UICollectionViewCell,
                let indexPath = collectionView?.indexPath(for: cell),
                let marketplaceDetailVC = segue.destination as? MarketplaceDetailTableViewController
                else { break }
            
            marketplaceDetailVC.newsItem = newsItems?[indexPath.row]
            self.marketplaceDetailVC = marketplaceDetailVC
  
        default:
            break
        }
        
    }
 
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

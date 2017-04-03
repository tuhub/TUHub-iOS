//
//  ListingsCollectionViewController.swift
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

class ListingsCollectionViewController: UICollectionViewController {
    
    lazy var listings: [Listing] = []
    fileprivate var images: [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Clear selection between presentations
         self.clearsSelectionOnViewWillAppear = true
        
        setupCollectionView()
        
        
        Product.retrieveAll { (products, error) in
            if let products = products {
                self.listings.append(contentsOf: products as [Listing])
                self.listings.sort(by: { $0.datePosted > $1.datePosted })
                self.collectionView?.reloadData()
            }
        }
        
        Job.retrieveAll { (jobs, error) in
            if let jobs = jobs {
                self.listings.append(contentsOf: jobs as [Listing])
                self.listings.sort(by: { $0.datePosted > $1.datePosted })
                self.collectionView?.reloadData()
            }
        }
        
        Personal.retrieveAll { (personals, error) in
            if let personals = personals {
                self.listings.append(contentsOf: personals as [Listing])
                self.listings.sort(by: { $0.datePosted > $1.datePosted })
                self.collectionView?.reloadData()
            }
        }
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
        
        guard let identifier = segue.identifier else { return }
        switch identifier {
            
        case listingDetailSegueID:
            
            guard let cell = sender as? UICollectionViewCell,
                let indexPath = collectionView?.indexPath(for: cell),
                let marketplaceDetailVC = segue.destination as? ListingDetailTableViewController
                else { break }
  
        default:
            break
        }
        
    }
 
}

// MARK: UICollectionViewDataSource
extension ListingsCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listings.count > 0 ? 1 : 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
//        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView, let newsItem = newsItems?[indexPath.row] {
//            imageView.af_setImage(withURL: newsItem.imageURLs.first!,
//                                  placeholderImage: nil,
//                                  filter: nil) { (response) in
//                                    if response.value != nil && self.images?[indexPath.row] == nil {
//                                        self.images?[indexPath.row] = response.result.value
//                                        collectionView.collectionViewLayout.invalidateLayout()
//                                    }
//            }
//        }
        
        return cell
    }
    
}

extension ListingsCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        
        guard let image = images?[indexPath.row]
            else { return CGSize(width: 50, height: 70) }
        return image.size
    }
}

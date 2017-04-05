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
import TLIndexPathTools

// Segue Identifiers
fileprivate let listingDetailSegueID = "showListingDetail"

private let reuseIdentifier = "marketplaceCell"

class ListingsCollectionViewController: TLCollectionViewController {
    
    private lazy var lock = NSLock()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        // Set up the collection view's appearance
        setupCollectionView()
        
        // Initialize indexPathController's data model
        indexPathController.dataModel = dataModel(for: [])
        
        Product.retrieveAll(onlyActive: true) { (products, error) in
            if let products = products {
                self.add(listings: products)
            }
        }
        
        Job.retrieveAll(onlyActive: true) { (jobs, error) in
            if let jobs = jobs {
                self.add(listings: jobs)
            }
        }
        
        Personal.retrieveAll(onlyActive: true) { (personals, error) in
            if let personals = personals {
                self.add(listings: personals)
            }
        }
    }
    
    func dataModel(for listings: [Listing]) -> TLIndexPathDataModel {
        return TLIndexPathDataModel(items: listings, sectionNameBlock: nil, identifierBlock: {
            if let listing = $0 as? Listing {
                let s = String(describing: type(of: listing)) + listing.id
                return s
            }
            return nil
        })
    }
    
    func add(listings: [Listing]) {
        // Entering critical section
        lock.lock()
        
        if var items = indexPathController.items as? [Listing] {
            items.append(contentsOf: listings)
            items.sort { $0.datePosted > $1.datePosted }
            indexPathController.dataModel = dataModel(for: items)
        }
        
        // Exiting critical section
        lock.unlock()
    }
    
    //MARK: - CollectionView UI Setup
    func setupCollectionView() {
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.minimumContentHeight = 44
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
                let listingDetailVC = segue.destination as? ListingDetailTableViewController
                else { break }
            
            listingDetailVC.listing = indexPathController.dataModel?.item(at: indexPath) as? Listing
        default:
            break
        }
        
    }
    
}

// MARK: UICollectionViewDataSource
extension ListingsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexPathController.dataModel?.numberOfSections ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indexPathController.dataModel?.numberOfRows(inSection: section) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let cell = cell as? ListingCollectionViewCell, let listing = indexPathController.dataModel?.item(at: indexPath) as? Listing {
            cell.setUp(listing, self)
        }
        
        return cell
    }
    
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension ListingsCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        guard let imageSize = (collectionView.cellForItem(at: indexPath) as? ListingCollectionViewCell)?.imageView.image?.size
            else { return CGSize(width: 50, height: 70) }
        return imageSize
    }
}

// MARK: - ImageLoadedDelegate
extension ListingsCollectionViewController: ImageLoadedDelegate {
    func didLoad(image: UIImage?) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

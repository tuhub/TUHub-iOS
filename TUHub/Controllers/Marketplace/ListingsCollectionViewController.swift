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

// MARK: - Segue IdentifierS
private let listingDetailSegueID = "showListingDetail"
private let listingFilterSegueID = "presentListingFilter"

// MARK: - Cell reuse identifiers
private let reuseIdentifier = "marketplaceCell"

class ListingsCollectionViewController: TLCollectionViewController {
    
    private lazy var lock = NSLock()
    
    @IBOutlet weak var composeButton: UIBarButtonItem!

    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = .cherry
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        return searchController
    }()
    
    // Keep track of how many of each type of listing is loaded for pagination
    private var numRowsProducts = 0
    private var numRowsJobs = 0
    private var numRowsPersonals = 0
    fileprivate lazy var selectedKinds: Set<Listing.Kind> = [.product, .job, .personal]
    
    var imageSizes = [IndexPath : CGSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        
        // Initialize indexPathController's data model
        indexPathController.dataModel = dataModel(for: [])
        
        // Retrieve listings
        loadListings()
        
        // Set up search controller
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.frame = CGRect(origin: .zero,
                                                  size: CGSize(width: collectionView!.frame.width,
                                                               height: 44))
        
        // Compose button should be disabled until we can authenticate the user
        composeButton.isEnabled = false
        
        // Add the search bar above the collection view
        collectionView!.addSubview(searchController.searchBar)
        
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = UIRefreshControl()
            collectionView?.refreshControl?.addTarget(self, action: #selector(refreshListings), for: .valueChanged)
        }
        
        // Set up the collection view's appearance
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MarketplaceUser.current == nil {
            self.composeButton.isEnabled = false
            if let userId = User.current?.username {
                MarketplaceUser.retrieve(user: userId) { (user, error) in
                    
                    if let error = error {
                        log.error(error)
                    }
                    else if let user = user {
                        MarketplaceUser.current = user
                        self.composeButton.isEnabled = true
                        return
                    }
                    
                    // Display sign up
                    let signUpVC = MarketplaceSignUpViewController()
                    signUpVC.userId = userId
                    let navVC = UINavigationController(rootViewController: signUpVC)
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        } else {
            self.composeButton.isEnabled = true
        }
    }
    
    func refreshListings() {
        loadListings(shouldClearResults: true)
    }
    
    func loadListings(selection: Set<Listing.Kind>? = nil, shouldClearResults: Bool = false) {
        
        if shouldClearResults {
            clearResults()
        }
        
        let selection = selection ?? [.product, .job, .personal]
        
        for kind in selection {
            switch kind {
            case .product:
                Product.retrieveAll() { (products, error) in
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                    if let products = products {
                        self.add(listings: products)
                    }
                }
            case .job:
                Job.retrieveAll() { (jobs, error) in
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                    if let jobs = jobs {
                        self.add(listings: jobs)
                    }
                }
            case .personal:
                Personal.retrieveAll() { (personals, error) in
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                    if let personals = personals {
                        self.add(listings: personals)
                    }
                }
            }
            
        }
    }
    
    func clearResults() {
        indexPathController.dataModel = nil
        imageSizes.removeAll()
    }
    
    func dataModel(for listings: [Listing]) -> TLIndexPathDataModel {
        return TLIndexPathDataModel(items: listings, sectionNameBlock: nil, identifierBlock: nil)
    }
    
    func add(listings: [Listing]) {
        // Entering critical section
        lock.lock()
        
        var listings = listings
        if let items = indexPathController.items as? [Listing] {
            listings.append(contentsOf: items)
            listings.sort { $0.datePosted > $1.datePosted }
        }
        indexPathController.dataModel = dataModel(for: listings)
        
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
        layout.sectionInset = UIEdgeInsets(top: searchController.searchBar.frame.height + 8, left: 16, bottom: 8, right: 16)
        
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
            
        case listingFilterSegueID:
            guard let filterVC = (segue.destination as? UINavigationController)?
                .childViewControllers.first as? ListingsFilterTableViewController
                else { break }
            
            filterVC.selectedKinds = selectedKinds
            filterVC.delegate = self
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
            cell.setUp(listing, self, indexPath)
        }
        
        return cell
    }
    
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension ListingsCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        guard let imageSize = imageSizes[indexPath]
            else { return CGSize(width: 30, height: 40) }
        return imageSize
    }
}

// MARK: - ImageLoadedDelegate
extension ListingsCollectionViewController: ImageLoadedDelegate {
    func didLoad(image: UIImage?, at indexPath: IndexPath) {
        imageSizes[indexPath] = image?.size
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

extension ListingsCollectionViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        clearResults()
        NetworkManager.shared.cancelAllRequests(for: .marketplace)
        
        for listingKind in selectedKinds {
            switch listingKind {
            case .product:
                Product.search(for: text) { (results, error) in
                    if let results = results {
                        self.add(listings: results)
                    }
                }
            case .job:
                Job.search(for: text) { (results, error) in
                    if let results = results {
                        self.add(listings: results)
                    }
                }
            case .personal:
                Personal.search(for: text) { (results, error) in
                    if let results = results {
                        self.add(listings: results)
                    }
                }
            }
        }
    }
}

extension ListingsCollectionViewController: ListingsFilterDelegate {
    func didSelect(listingKinds: Set<Listing.Kind>) {
        if self.selectedKinds != listingKinds {
            self.selectedKinds = listingKinds
            loadListings(selection: listingKinds, shouldClearResults: true)
        }
    }
}

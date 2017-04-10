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
    
    fileprivate var isSearching = false
    
    // Keep track of how many of each type of listing is loaded for pagination
    fileprivate var numRowsProducts = 0
    fileprivate var numRowsJobs = 0
    fileprivate var numRowsPersonals = 0
    fileprivate var lastProduct: Product?
    fileprivate var lastJob: Job?
    fileprivate var lastPersonal: Personal?
    
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
        searchController.delegate = self
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
                    
                    let defaults = UserDefaults.standard
                    let key = "hasPromptedSignIn"
                    if !defaults.bool(forKey: key) {
                        // Display sign up
                        let signUpVC = MarketplaceSignUpViewController()
                        signUpVC.userId = userId
                        let navVC = UINavigationController(rootViewController: signUpVC)
                        self.present(navVC, animated: true, completion: nil)
                        defaults.set(true, forKey: key)
                    }

                }
            }
        } else {
            self.composeButton.isEnabled = true
        }
    }
    
    func refreshListings() {
        loadListings(shouldClearResults: true)
    }
    
    func loadListings(selection: Set<Listing.Kind>? = nil, startIndex: Int = 0, shouldClearResults: Bool = false) {
        
        if shouldClearResults {
            clearResults()
        }
        
        let selection = selection ?? [.product, .job, .personal]
        
        for kind in selection {
            switch kind {
            case .product:
                Product.retrieveAll(startIndex: startIndex) { (products, error) in
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                    if let products = products {
                        self.add(listings: products)
                        self.numRowsProducts += products.count
                        self.lastProduct = products.last
                    }
                }
            case .job:
                Job.retrieveAll(startIndex: startIndex) { (jobs, error) in
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                    if let jobs = jobs {
                        self.add(listings: jobs)
                        self.numRowsJobs +=  jobs.count
                        self.lastJob = jobs.last
                    }
                }
            case .personal:
                Personal.retrieveAll(startIndex: startIndex) { (personals, error) in
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                    if let personals = personals {
                        self.add(listings: personals)
                        self.numRowsPersonals += personals.count
                        self.lastPersonal = personals.last
                    }
                }
            }
            
        }
    }
    
    func clearResults() {
        indexPathController.dataModel = nil
        imageSizes.removeAll()
        collectionView?.collectionViewLayout.invalidateLayout()
        self.numRowsProducts = 0
        self.numRowsJobs = 0
        self.numRowsPersonals = 0
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let layout = collectionView?.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            if traitCollection.verticalSizeClass == .regular {
                if traitCollection.horizontalSizeClass == .regular {
                    layout.columnCount = 4
                } else {
                    layout.columnCount = 2
                }
            } else {
                if traitCollection.horizontalSizeClass == .regular {
                    layout.columnCount = 4
                } else {
                    layout.columnCount = 3
                }
            }
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        var frame = searchController.searchBar.frame
        frame.size.width = collectionView!.frame.width
        searchController.searchBar.frame = frame
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
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        
//        guard !searchController.isActive else { return }
//        
//        if let listing = indexPathController.dataModel?.item(at: indexPath) {
//            if let product = listing as? Product, let lastProduct = lastProduct  {
//                if product.id == lastProduct.id {
//                    loadListings(selection: [.product], startIndex: numRowsProducts)
//                }
//            }
//            else if let job = listing as? Job, let lastJob = lastJob {
//                if job.id == lastJob.id {
//                    loadListings(selection: [.job], startIndex: numRowsJobs)
//                }
//            }
//            else if let personal = listing as? Personal, let lastPersonal = lastPersonal {
//                if personal.id == lastPersonal.id {
//                    loadListings(selection: [.personal], startIndex: numRowsPersonals)
//                }
//            }
//        }
//    }
    
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension ListingsCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        guard let imageSize = imageSizes[indexPath] ?? (collectionView.cellForItem(at: indexPath) as? ListingCollectionViewCell)?.imageView.image?.size
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
        
        guard let text = searchController.searchBar.text, text.characters.count > 0 else { return }
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

extension ListingsCollectionViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        loadListings(selection: selectedKinds, shouldClearResults: true)
    }
}

// MARK: - ListingsFilterDelegate
extension ListingsCollectionViewController: ListingsFilterDelegate {
    func didSelect(listingKinds: Set<Listing.Kind>) {
        if self.selectedKinds != listingKinds {
            self.selectedKinds = listingKinds
            loadListings(selection: listingKinds, shouldClearResults: true)
        }
    }
}

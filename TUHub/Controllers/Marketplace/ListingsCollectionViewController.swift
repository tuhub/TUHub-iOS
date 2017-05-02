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

// MARK: - Segue IdentifierS
private let listingDetailSegueID = "showListingDetail"
private let listingFilterSegueID = "presentListingFilter"
private let addListingSegueID = "presentAddListing"

// MARK: - Cell reuse identifiers
private let reuseIdentifier = "marketplaceCell"

class ListingsCollectionViewController: UICollectionViewController {
    
    private lazy var lock = NSLock()
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    @IBOutlet weak var meButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.tintColor = .cherry
        searchController.searchBar.placeholder = "Search for listings by title"
        searchController.searchBar.frame = CGRect(origin: .zero, size: CGSize(width: self.collectionView!.frame.width, height: 44))
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        self.definesPresentationContext = true
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
    
    lazy var listings = [Listing]()
    lazy var imageSizes = [IndexPath : CGSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = searchController
        
        // Clear selection between presentations
        clearsSelectionOnViewWillAppear = true
        
        // Retrieve listings
        loadListings()
        
        // Compose and Me button should be disabled until we can authenticate the user
        composeButton.isEnabled = false
        meButton.isEnabled = false
        
        // Add the search bar above the collection view
        collectionView!.addSubview(searchController.searchBar)
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.backgroundColor = .cherry
            refreshControl.tintColor = .white
            collectionView?.refreshControl = refreshControl
            collectionView?.refreshControl?.addTarget(self, action: #selector(refreshListings), for: .valueChanged)
        }
        
        // Set up the collection view's appearance
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MarketplaceUser.current == nil {            
            if let userId = User.current?.username {
                MarketplaceUser.retrieve(user: userId) { (user, error) in
                    
                    if let error = error {
                        log.error(error)
                    }
                    else if let user = user {
                        MarketplaceUser.current = user
                        self.meButton.isEnabled = true
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
            self.meButton.isEnabled = true
        }
        filterButton.image = #imageLiteral(resourceName: "FilterIcon")
    }
    
    func refreshListings() {
        loadListings(selection: selectedKinds, shouldClearResults: true)
    }
    
    func loadListings(selection: Set<Listing.Kind>? = nil, startIndex: Int = 0, shouldClearResults: Bool = false) {
        let selection = selection ?? [.product, .job, .personal]
        
        if shouldClearResults {
            clearResults()
        }
        
        // Wait for all download tasks to complete
        let dispatchGroup = DispatchGroup()
        for kind in selection {
            switch kind {
            case .product:
                dispatchGroup.enter()
                Product.retrieveAll(startIndex: startIndex) { (products, error) in
                    if let products = products {
                        self.add(listings: products)
                        self.numRowsProducts += products.count
                        self.lastProduct = products.last
                    }
                    dispatchGroup.leave()
                }
            case .job:
                dispatchGroup.enter()
                Job.retrieveAll(startIndex: startIndex) { (jobs, error) in
                    if let jobs = jobs {
                        self.add(listings: jobs)
                        self.numRowsJobs +=  jobs.count
                        self.lastJob = jobs.last
                    }
                    dispatchGroup.leave()
                }
            case .personal:
                dispatchGroup.enter()
                Personal.retrieveAll(startIndex: startIndex) { (personals, error) in
                    if let personals = personals {
                        self.add(listings: personals)
                        self.numRowsPersonals += personals.count
                        self.lastPersonal = personals.last
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { 
            // All done, reload the collection view!
            if #available(iOS 10.0, *) {
                self.collectionView?.refreshControl?.endRefreshing()
            }
            self.collectionView?.reloadData()
        }
    }
    
    func clearResults() {
        listings.removeAll()
        imageSizes.removeAll()
        collectionView?.reloadData()
        self.numRowsProducts = 0
        self.numRowsJobs = 0
        self.numRowsPersonals = 0
    }
    
    func add(listings: [Listing]) {
        // Entering critical section
        lock.lock()
        
        self.listings.append(contentsOf: listings)
        self.listings.sort { $0.datePosted > $1.datePosted }
        
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
            
            listingDetailVC.listing = listings[indexPath.row]
            
        case listingFilterSegueID:
            guard let filterVC = (segue.destination as? UINavigationController)?
                .childViewControllers.first as? ListingsFilterTableViewController
                else { break }
            
            filterVC.selectedKinds = selectedKinds
            filterVC.delegate = self
        case addListingSegueID:
            guard let addVC = (segue.destination as? UINavigationController)?
                .childViewControllers.first as? AddListingViewController
                else { break }
            
            addVC.delegate = self
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
        
        if let cell = cell as? ListingCollectionViewCell {
            let listing = listings[indexPath.row]
            cell.setUp(listing, self)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !searchController.isActive else { return }
        
        let listing = listings[indexPath.row]
        if let product = listing as? Product, let lastProduct = lastProduct  {
            if product.id == lastProduct.id {
                self.lastProduct = nil
                loadListings(selection: [.product], startIndex: numRowsProducts)
            }
        }
        else if let job = listing as? Job, let lastJob = lastJob {
            if job.id == lastJob.id {
                self.lastJob = nil
                loadListings(selection: [.job], startIndex: numRowsJobs)
            }
        }
        else if let personal = listing as? Personal, let lastPersonal = lastPersonal {
            if personal.id == lastPersonal.id {
                self.lastPersonal = nil
                loadListings(selection: [.personal], startIndex: numRowsPersonals)
            }
        }
    }
    
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension ListingsCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        return imageSizes[indexPath] ?? CGSize(width: 30, height: 40)
    }
}

// MARK: - ImageLoadedDelegate
extension ListingsCollectionViewController: ListingCollectionViewCellDelegate {
    func cell(_ cell: ListingCollectionViewCell, didLoadImage image: UIImage?) {
        
        if let indexPath = collectionView?.indexPathForItem(at: cell.center) {
            if imageSizes[indexPath] != image?.size {
                imageSizes[indexPath] = image?.size
                collectionView?.reloadItems(at: [indexPath])
            }
        }
    }
}

extension ListingsCollectionViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text, text.characters.count > 0 else { return }
        NetworkManager.shared.cancelAllRequests(for: .marketplace)
        clearResults()
        
        let dispatchGroup = DispatchGroup()
        for listingKind in selectedKinds {
            switch listingKind {
            case .product:
                dispatchGroup.enter()
                Product.search(for: text) { (results, error) in
                    if let results = results {
                        self.add(listings: results)
                        self.numRowsProducts += results.count
                        self.lastProduct = results.last
                        dispatchGroup.leave()
                    }
                }
            case .job:
                dispatchGroup.enter()
                Job.search(for: text) { (results, error) in
                    if let results = results {
                        self.add(listings: results)
                        self.numRowsJobs += results.count
                        self.lastJob = results.last
                        dispatchGroup.leave()
                    }
                }
            case .personal:
                dispatchGroup.enter()
                Personal.search(for: text) { (results, error) in
                    if let results = results {
                        self.add(listings: results)
                        self.numRowsPersonals += results.count
                        self.lastPersonal = results.last
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // All done, reload the collection view!
            if #available(iOS 10.0, *) {
                self.collectionView?.refreshControl?.endRefreshing()
            }
            self.collectionView?.reloadData()
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

extension ListingsCollectionViewController: AddListingViewControllerDelegate {
    func didAdd(listing: Listing) {
        // Insert the listing at the top of the collection view
        listings.insert(listing, at: 0)
        collectionView?.reloadData()
    }
}

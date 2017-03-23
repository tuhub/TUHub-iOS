//
//  NewsTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

// Segue Identifiers
fileprivate let newsDetailSegueID = "showNewsDetail"
fileprivate let newsFilterSegueID = "showNewsFilter"

// UITableViewCell reuse identifier
fileprivate let newsItemCellID = "newsItemCell"

class NewsTableViewController: UITableViewController {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    fileprivate var newsItems: [NewsItem]?
    fileprivate var searchResults: [NewsItem]?
    fileprivate weak var newsDetailVC: NewsDetailTableViewController?
    fileprivate var selectedFeeds: Set<NewsItem.Feed>?
    private var errorLabel: UILabel?
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = .cherry
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the split view controller's delegate
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible

        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Begin showing refresh indicator
        tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl!.frame.size.height) // Needed to fix refresh control bug
        refreshControl?.tintColor = UIColor.white
        refreshControl?.backgroundColor = UIColor.cherry
        
        // Set search bar as the table view's header
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        
        load(feeds: nil)
    }

    func load(feeds: [NewsItem.Feed]?) {
        if !refreshControl!.isRefreshing {
            refreshControl?.beginRefreshing()
        }
        NewsItem.retrieve(fromFeeds: feeds ?? NewsItem.Feed.allValues) { (newsItems, error) in
            
            // Remove old message from view
            self.errorLabel?.removeFromSuperview()
            
            self.newsItems = newsItems
            self.tableView.reloadData()
            // End showing refresh indicator
            self.refreshControl?.endRefreshing()
            
            
            if let _ = error {
                // Create label containing error message
                let errorMessage = "Something went wrong. ☹️"
                self.showErrorLabel(with: errorMessage)
            } else if newsItems == nil || newsItems!.isEmpty {
                self.showErrorLabel(with: "Looks like there's nothing here.")
            } else if let splitViewController = self.splitViewController, !splitViewController.isCollapsed {
                // Manually trigger segue to show first result so detail view controller is not empty
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                
                let cell = self.tableView.cellForRow(at: indexPath)
                self.performSegue(withIdentifier: newsDetailSegueID, sender: cell)
            }
        }
    }
    
    fileprivate func showErrorLabel(with text: String) {
        let width = tableView.contentSize.width
        let height = text.height(withConstrainedWidth: width, font: UIFont.preferredFont(forTextStyle: .body))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.textColor = .darkText
        label.textAlignment = .center
        label.text = text
        
        // Add to view
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.bringSubview(toFront: label)
        self.view.addConstraint(
            NSLayoutConstraint(item: label,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: self.tableView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1,
                               constant: 0))
        self.view.addConstraint(
            NSLayoutConstraint(item: label,
                               attribute: NSLayoutAttribute.centerY,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: self.tableView,
                               attribute: NSLayoutAttribute.centerY,
                               multiplier: 0.75,
                               constant: 0))
        
        self.errorLabel = label

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case newsDetailSegueID:
            
            guard let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let newsDetailVC = (segue.destination as? UINavigationController)?.childViewControllers.first as? NewsDetailTableViewController
                else { break }
            
            newsDetailVC.newsItem = searchResults?[indexPath.row] ?? newsItems?[indexPath.row]
            self.newsDetailVC = newsDetailVC
            
        case newsFilterSegueID:
            
            guard let newsFilterVC = (segue.destination as? UINavigationController)?.childViewControllers.first as? NewsFilterTableViewController
                else { break }
            newsFilterVC.delegate = self
            newsFilterVC.selectedFeeds = selectedFeeds ?? Set(NewsItem.Feed.allValues)
            
        default:
            break
        }
        
    }
    
    @IBAction func didTriggerRefresh(_ sender: UIRefreshControl) {
        load(feeds: selectedFeeds == nil ? nil : Array(selectedFeeds!))
    }

}

// MARK: - UITableViewDataSource
extension NewsTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (searchResults != nil || newsItems != nil) ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? newsItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsItemCellID, for: indexPath)
        
        if let cell = cell as? NewsItemTableViewCell, let newsItem = searchResults?[indexPath.row] ?? newsItems?[indexPath.row] {
            cell.setUp(from: newsItem)
        }
        
        return cell
    }
    
}

// MARK: - UISplitViewControllerDelegate
extension NewsTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // By returning true, we prevent the detail view controller from being the first view controller presented
        return true
    }
    
}

// MARK: - NewsFilterDelegate
extension NewsTableViewController: NewsFilterDelegate {
    
    func didSelect(feeds: Set<NewsItem.Feed>) {
        self.selectedFeeds = feeds
        load(feeds: Array(feeds))
        
        if feeds.count < NewsItem.Feed.allValues.count {
            filterButton.image = #imageLiteral(resourceName: "FilterIcon-Filled")
        } else {
            filterButton.image = #imageLiteral(resourceName: "FilterIcon")
        }
    }
    
}

// MARK: - UISearchResultsUpdating
extension NewsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, let newsItems = newsItems, searchText.characters.count > 0 else {
            searchResults = nil
            tableView.reloadData()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            struct Result {
                var newsItem: NewsItem
                var index: String.Index
            }
            
            var results = [Result]()
            
            // Find matches
            for item in newsItems {
                var minIndex: String.Index? = item.title.index(of: searchText)
                if let i = item.description?.index(of: searchText) {
                    if minIndex == nil || i < minIndex! {
                        minIndex = i
                    }
                }
                if let i = item.subtitle?.index(of: searchText) {
                    if minIndex == nil || i < minIndex! {
                        minIndex = i
                    }
                }
                
                if let minIndex = minIndex {
                    results.append(Result(newsItem: item, index: minIndex))
                }
            }
            
            // Sort by closeness then date
            results.sort {
                if $0.index == $1.index {
                    return $0.newsItem.date > $1.newsItem.date
                }
                return $0.index < $1.index
            }
            
            self.searchResults = results.map { $0.newsItem }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
}

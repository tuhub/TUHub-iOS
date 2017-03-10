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
    fileprivate weak var newsDetailVC: NewsDetailTableViewController?
    fileprivate var selectedFeeds: Set<NewsItem.Feed>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the split view controller's delegate
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible

        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Begin showing refresh indicator
        refreshControl?.beginRefreshing()
        refreshControl?.backgroundColor = UIColor.cherry
        refreshControl?.tintColor = UIColor.white
        
        load(feeds: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func load(feeds: [NewsItem.Feed]?) {
        NewsItem.retrieve(fromFeeds: feeds ?? NewsItem.Feed.allValues) { (newsItems, error) in
            if let newsItems = newsItems {
                self.newsItems = newsItems
                self.tableView.reloadData()
            }
            // End showing refresh indicator
            self.refreshControl?.endRefreshing()
            //            if let error = error {
            //                // TODO: Handle error
            //            }
        }
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
            
            newsDetailVC.newsItem = newsItems?[indexPath.row]
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsItemCellID, for: indexPath)
        
        if let cell = cell as? NewsItemTableViewCell, let newsItem = newsItems?[indexPath.row] {
            cell.setUp(from: newsItem)
        }
        
        return cell
    }
    
}


// MARK: - UITableViewDelegate
extension NewsTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Begin downloading the cell's corresponding NewsItem's image
        if let newsItem = newsItems?[indexPath.row] {
            if newsItem.image == nil && !newsItem.isDownloadingImage {
                
                // About to display cell that does not have an image, load the image and display in cell when ready
                newsItem.downloadImage { (entryID, image, error) in
                    if let image = image, let newsItems = self.newsItems {
                        // Find the cell where the image should go
                        let index = newsItems.index(where: { return $0.entryID == entryID })
                        if let index = index {
                            let indexPath = IndexPath(row: index, section: 0)
                            if let cell = tableView.cellForRow(at: indexPath) as? NewsItemTableViewCell {
                                cell.thumbnailImageView.image = image
                            }
                        }
                        
                        // If showing the news detail view controller, tell it to update to show image
                        if self.newsDetailVC?.newsItem?.entryID == entryID {
                            self.newsDetailVC?.newsBodyCell?.updateImageView(with: image)
                        }
                        
                    }
                    //                    if let error = error {
                    //                        // TODO: Handle error
                    //                    }
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Try to asynchronously parse HTML before performing segue
        if let newsItem = newsItems?[indexPath.row] {
            newsItem.parseContent {
                self.performSegue(withIdentifier: newsDetailSegueID, sender: tableView.cellForRow(at: indexPath))
            }
        }
        
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

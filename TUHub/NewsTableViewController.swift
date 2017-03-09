//
//  NewsTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    fileprivate var newsItems: [NewsItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the split view controller's delegate
        splitViewController?.delegate = self

        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        NewsItem.retrieve(fromFeeds: [.all]) { (newsItems, error) in
            if let newsItems = newsItems {
                self.newsItems = newsItems
                self.tableView.reloadData()
            }
            if let error = error {
                // TODO: Handle error
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell", for: indexPath)
        
        if let cell = cell as? NewsItemTableViewCell, let newsItem = newsItems?[indexPath.row] {
            cell.setUp(from: newsItem)
        }

        return cell
    }

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
                    }
                    if let error = error {
                        // TODO: Handle error
                    }
                }
                
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let newsDetailVC = (segue.destination as? UINavigationController)?.childViewControllers.first as? NewsDetailTableViewController
            else { return }
        
        newsDetailVC.newsItem = newsItems?[indexPath.row]
        
    }

}

extension NewsTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // By returning true, we prevent the detail view controller from being the first view controller presented
        return true
    }
    
}

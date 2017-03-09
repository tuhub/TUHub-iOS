//
//  NewsDetailTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class NewsDetailTableViewController: UITableViewController {

    var newsItem: NewsItem? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        // Add button to switch display mode for split view controller
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsItem == nil ? 0 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let newsItem = newsItem else {
            return UITableViewCell()
        }
        
        var cell: UITableViewCell!
        
        if indexPath.row == 0 {
            if let headerCell = tableView.dequeueReusableCell(withIdentifier: "newsHeaderCell", for: indexPath) as? NewsHeaderTableViewCell {
                headerCell.setUp(from: newsItem)
                cell = headerCell
            }
            
        } else if indexPath.row == 1 {
            if let bodyCell = tableView.dequeueReusableCell(withIdentifier: "newsBodyCell", for: indexPath) as? NewsBodyTableViewCell {
                bodyCell.setUp(from: newsItem)
                cell = bodyCell
            }
            
        }

        return cell
    }
    
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer) {
        
        if let image = newsItem?.image,
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NewsBodyTableViewCell {
            // 1. create SKPhoto Array from UIImage
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(image)
            images.append(photo)
            
            // 2. create PhotoBrowser Instance, and present from your viewController.
            let browser = SKPhotoBrowser(originImage: image, photos: images, animatedFromView: cell.newsImageView)
            browser.initializePageIndex(0)
            present(browser, animated: true, completion: {})
        }
        
    }
    
}

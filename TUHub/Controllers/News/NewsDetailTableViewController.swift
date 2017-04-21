//
//  NewsDetailTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import SafariServices
import TUSafariActivity

fileprivate let newsHeaderCellID = "newsHeaderCell"
fileprivate let newsImageGalleryCellID = "newsImageGalleryCell"
fileprivate let newsBodyCellID = "newsBodyCell"

class NewsDetailTableViewController: UITableViewController {

    fileprivate var peekPopSourceRect: CGRect?
    
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
//        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        tableView.register(UINib(nibName: "ImageGalleryTableViewCell", bundle: nil), forCellReuseIdentifier: newsImageGalleryCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add button to switch display mode for split view controller
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItem == nil ? 0 : 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newsItem = self.newsItem!
        var cell: UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: newsHeaderCellID, for: indexPath)
            (cell as? NewsHeaderTableViewCell)?.setUp(from: newsItem)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: newsImageGalleryCellID, for: indexPath)
            if let cell = cell as? ImageGalleryTableViewCell {
                cell.setUp(with: newsItem.imageURLs)
                cell.delegate = self
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: newsBodyCellID, for: indexPath)
            (cell as? NewsBodyTableViewCell)?.setUp(with: newsItem, from: tableView)
        default:
            break
        }
        
        return cell
    }
    
    @IBAction func didPressShare(_ sender: UIBarButtonItem) {
        if let url = newsItem?.url {
            let openSafariActivity = TUSafariActivity()
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [openSafariActivity])
            let barButtonItem = self.navigationItem.rightBarButtonItem
            let buttonItemView = barButtonItem?.value(forKey: "view") as? UIView
            activityVC.popoverPresentationController?.sourceView = buttonItemView
            present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - ImageGalleryTableViewCellDelegate
extension NewsDetailTableViewController: ImageGalleryTableViewCellDelegate {
    func didSelect(imageView: UIImageView, from images: [SKPhoto], at row: Int) {
        if let image = imageView.image {
            let browser = SKPhotoBrowser(originImage: image, photos: images, animatedFromView: imageView)
            browser.initializePageIndex(row)
            present(browser, animated: true, completion: nil)
        }
    }
}

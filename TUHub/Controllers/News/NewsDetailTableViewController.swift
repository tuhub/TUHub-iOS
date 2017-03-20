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

fileprivate let newsHeaderCellID = "newsHeaderCell"
fileprivate let newsImageCellID = "newsImageCell"
fileprivate let newsBodyCellID = "newsBodyCell"

class NewsDetailTableViewController: UITableViewController {

    weak var newsImageCell: NewsImageTableViewCell?
    fileprivate var peekPopSourceRect: CGRect?
    fileprivate var safariVC: SFSafariViewController?
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add button to switch display mode for split view controller
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItem == nil ? 0 : 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let newsItem = newsItem else {
            return UITableViewCell()
        }
        
        var cell: UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: newsHeaderCellID, for: indexPath)
            (cell as? NewsHeaderTableViewCell)?.setUp(from: newsItem)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: newsImageCellID, for: indexPath)
            newsImageCell = cell as? NewsImageTableViewCell
            newsImageCell?.tableView = self.tableView
            newsImageCell?.newsImageView.image = newsItem.image
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: newsBodyCellID, for: indexPath)
            let cell = cell as? NewsBodyTableViewCell
            cell?.setUp(with: newsItem, from: tableView)
            cell?.contentTextView.delegate = self
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer) {
        
        if let image = newsItem?.image,
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NewsImageTableViewCell {
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
    
    @IBAction func didPressShare(_ sender: UIBarButtonItem) {
        if let url = newsItem?.url {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            let barButtonItem = self.navigationItem.rightBarButtonItem
            let buttonItemView = barButtonItem?.value(forKey: "view") as? UIView
            activityVC.popoverPresentationController?.sourceView = buttonItemView
            present(activityVC, animated: true, completion: nil)
        }
    }
}

extension NewsDetailTableViewController: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let scheme = URL.scheme, scheme == "http" || scheme == "https", interaction == .invokeDefaultAction {
            let svc = SFSafariViewController(url: URL)
            present(svc, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if let scheme = URL.scheme, scheme == "http" || scheme == "https" {
            let svc = SFSafariViewController(url: URL)
            present(svc, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
}

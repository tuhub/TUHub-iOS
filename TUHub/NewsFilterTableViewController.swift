//
//  NewsFilterTableViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/9/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

protocol NewsFilterDelegate {
    func didSelect(feeds: Set<NewsItem.Feed>)
}

fileprivate let newsFilterCellID = "newsFilterCell"

class NewsFilterTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var delegate: NewsFilterDelegate?
    var selectedFeeds: Set<NewsItem.Feed>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        preferredContentSize = tableView.contentSize
//        let height = NewsItem.Feed.allValues.count * Int(tableView.rowHeight)
//        navigationController?.preferredContentSize = CGSize(width: 300, height: height)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewsItem.Feed.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsFilterCellID, for: indexPath)
        
        let feed = NewsItem.Feed.allValues[indexPath.row]
        cell.textLabel?.text = feed.name
        cell.accessoryType = selectedFeeds.contains(feed) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Add feed to selected feed if not selected, remove from selected feeds if selected
        let feed = NewsItem.Feed.allValues[indexPath.row]
        if selectedFeeds.contains(feed) {
            selectedFeeds.remove(feed)
        } else {
            selectedFeeds.insert(feed)
        }
        
        // Enable or disable the done button based on whether or not any feeds are selected
        doneButton.isEnabled = selectedFeeds.count > 0
        
        // Reload row to show/hide checkmark
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    

    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressDone(_ sender: Any) {
        delegate?.didSelect(feeds: selectedFeeds)
        dismiss(animated: true, completion: nil)
    }
    
}

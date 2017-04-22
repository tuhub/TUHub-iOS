//
//  WebPageViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

var url = ""

class WebPageViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.contentInset = UIEdgeInsets.zero

        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        
    }
    
    @IBAction func didPressRefresh(_ sender: Any) {
        webView.reload()
    }
}

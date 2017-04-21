//
//  WebPageViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/20/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class WebPageViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TUMail"

        if let url = URL(string: "https://tumail.temple.edu/") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        
    }
    
    @IBAction func didPressRefresh(_ sender: Any) {
        webView.reload()
    }
}

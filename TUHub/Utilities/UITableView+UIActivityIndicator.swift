//
//  UITableView+UIActivityIndicator.swift
//  TUHub
//
//  Created by Connor Crawford on 4/4/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

private func createActivityIndicator(_ frame: CGRect) -> UIActivityIndicatorView {
    let activityIndicator = UIActivityIndicatorView(frame: frame)
    activityIndicator.activityIndicatorViewStyle = .gray
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
}

extension UITableView {
    
    func showActivityIndicator() {
        let activityIndicator = (self.backgroundView as? UIActivityIndicatorView) ?? createActivityIndicator(self.frame)
        self.backgroundView = activityIndicator
        tableHeaderView?.isHidden = true
        tableFooterView?.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        guard let activityIndicator = self.backgroundView as? UIActivityIndicatorView else { return }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        tableHeaderView?.isHidden = false
        tableFooterView?.isHidden = false
    }
}

extension UICollectionView {
    
    func showActivityIndicator() {
        let activityIndicator = (self.backgroundView as? UIActivityIndicatorView) ?? createActivityIndicator(self.frame)
        self.backgroundView = activityIndicator
    }
    
    func hideActivityIndicator() {
        guard let activityIndicator = self.backgroundView as? UIActivityIndicatorView else { return }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
}

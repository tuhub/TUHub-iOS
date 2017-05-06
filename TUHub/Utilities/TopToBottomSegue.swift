//
//  TopToBottomSegue.swift
//  TUHub
//
//  Created by Connor Crawford on 5/6/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class TopToBottomSegue: UIStoryboardSegue {
    
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: -src.view.frame.size.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { _ in
            src.present(dst, animated: false, completion: nil)
        }
    }
    
    
}

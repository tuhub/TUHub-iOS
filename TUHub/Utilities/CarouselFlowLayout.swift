//
//  CarouselFlowLayout.swift
//  TUHub
//
//  Created by Connor Crawford on 3/22/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class CarouselFlowLayout: UPCarouselFlowLayout {
    
    override func invalidateLayout() {
        guard let collectionView = collectionView else { return }
        let height = collectionView.bounds.height
        let width = collectionView.bounds.width - 44
        self.itemSize = CGSize(width: width, height: height)
        super.invalidateLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}

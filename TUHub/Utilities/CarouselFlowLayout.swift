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
        self.itemSize = CGSize(width: collectionView.bounds.width - 44, height: collectionView.bounds.height)
        super.invalidateLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}

//
//  ImagesPickerCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/7/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka

class ImagesPickerCell: Cell<Set<UIImage>>, CellType, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (images?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        if let images = images, let cell = cell as? ImagePickerCollectionViewCell, indexPath.row < images.count {
            cell.imageView.image = images[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // TODO: Delete image
        if let images = images, indexPath.row < images.count {
            
        }
        
        // TODO: Display image picker
        if indexPath.row == (images?.count ?? 0) {
            
        }
        
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
//final class ImagesPickerRow: SelectorRow<ImagesPickerCell, ImagePickerController>,  PresenterRowType {
//
//    
//    required public init(tag: String?) {
//        super.init(tag: tag)
//        // We set the cellProvider to load the .xib corresponding to our cell
//        cellProvider = CellProvider<ImagesPickerCell>(nibName: "ImagesPickerCell")
//    }
//    
//}

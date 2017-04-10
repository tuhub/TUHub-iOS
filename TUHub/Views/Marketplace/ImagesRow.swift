//
//  ImagesPickerCell.swift
//  TUHub
//
//  Created by Connor Crawford on 4/7/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Eureka

public struct ImageRowSourceTypes : OptionSet {
    
    public let rawValue: Int
    public var imagePickerControllerSourceTypeRawValue: Int { return self.rawValue >> 1 }
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    init(_ sourceType: UIImagePickerControllerSourceType) { self.init(rawValue: 1 << sourceType.rawValue) }
    
    public static let photoLibrary  = ImageRowSourceTypes(.photoLibrary)
    public static let camera  = ImageRowSourceTypes(.camera)
    public static let savedPhotosAlbum = ImageRowSourceTypes(.savedPhotosAlbum)
    public static let all: ImageRowSourceTypes = [camera, photoLibrary, savedPhotosAlbum]
    
}

extension ImageRowSourceTypes {
    
    // MARK: Helpers
    
    var localizedString: String {
        switch self {
        case ImageRowSourceTypes.camera:
            return NSLocalizedString("Take photo", comment: "")
        case ImageRowSourceTypes.photoLibrary:
            return NSLocalizedString("Photo Library", comment: "")
        case ImageRowSourceTypes.savedPhotosAlbum:
            return NSLocalizedString("Saved Photos", comment: "")
        default:
            return ""
        }
    }
}

public enum ImageClearAction {
    case no
    case yes(style: UIAlertActionStyle)
}

public protocol ImagesCellDelegate {
    func didSelectCell(at row: Int)
}

public final class ImagesCell: Cell<ImageCollection>, CellType, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView?
    
    public fileprivate(set) var images: ImageCollection?
    var delegate: ImagesCellDelegate?
    
    public override func setup() {
        collectionView?.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.reloadData()
        super.setup()
    }
    
    public override func update() {
        super.update()
        collectionView?.reloadData()
        
        if let count = images?.images.count {
            collectionView?.scrollToItem(at: IndexPath(row: count, section: 0), at: .right, animated: true)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + (images?.images.count ?? 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        if let imageURLs = images?.images, let cell = cell as? ImageCollectionViewCell {
            let row = indexPath.row
            if row < imageURLs.count {
                cell.imageView.image = images?.images[row]
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCell(at: indexPath.row)
    }
}

//MARK: Row
public final class ImagesRow: SelectorRow<ImagesCell, ImagePickerController>, RowType, ImagesCellDelegate {

    public var sourceTypes: ImageRowSourceTypes
    public var clearAction = ImageClearAction.yes(style: .destructive)
    
    private var _sourceType: UIImagePickerControllerSourceType = .camera
    
    public required init(tag: String?) {
        sourceTypes = .all
        super.init(tag: tag)
        
        cellProvider = CellProvider<ImagesCell>(nibName: "ImagesCell")
        cell.delegate = self
        
        presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return ImagePickerController() }, onDismiss: { [weak self] vc in
            vc.dismiss(animated: true)
            self?.cell.images = self?.value
            self?.cell.update()
        })
        self.displayValueFor = nil
        
    }
    
    // copy over the existing logic from the SelectorRow
    func displayImagePickerController(_ sourceType: UIImagePickerControllerSourceType) {
        if let presentationMode = presentationMode, !isDisabled {
            if let controller = presentationMode.makeController(){
                controller.row = self
                controller.sourceType = sourceType
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
            }
            else{
                _sourceType = sourceType
                presentationMode.present(nil, row: self, presentingController: cell.formViewController()!)
            }
        }
    }

    public func didSelectCell(at row: Int) {
        var availableSources: ImageRowSourceTypes = []
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let _ = availableSources.insert(.photoLibrary)
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let _ = availableSources.insert(.camera)
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let _ = availableSources.insert(.savedPhotosAlbum)
        }
        
        sourceTypes.formIntersection(availableSources)
        
        if sourceTypes.isEmpty {
            super.customDidSelect()
            return
        }
        
        // now that we know the number of actions aren't empty
        let sourceActionSheet = UIAlertController(title: nil, message: selectorTitle, preferredStyle: .actionSheet)
        if let popView = sourceActionSheet.popoverPresentationController {
            popView.sourceView = cell.collectionView
            popView.sourceRect = cell.collectionView!.cellForItem(at: IndexPath(row: row, section: 0))!.frame
        }
        createOptionsForAlertController(sourceActionSheet)
        
        if case .yes(let style) = clearAction, let images = value?.images, row < images.count {
            let clearPhotoOption = UIAlertAction(title: "Clear Photo", style: style, handler: { [weak self] _ in
                self?.value?.images.remove(at: row)
                self?.cell.images = self?.value
                self?.updateCell()
            })
            sourceActionSheet.addAction(clearPhotoOption)
        }
        
        // check if we have only one source type given
        if sourceActionSheet.actions.count == 1 {
            if let imagePickerSourceType = UIImagePickerControllerSourceType(rawValue: sourceTypes.imagePickerControllerSourceTypeRawValue) {
                displayImagePickerController(imagePickerSourceType)
            }
        } else {
            let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
            sourceActionSheet.addAction(cancelOption)
            
            if let presentingViewController = cell.formViewController() {
                presentingViewController.present(sourceActionSheet, animated: true)
            }
        }

    }
    
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? ImagePickerController else {
            return
        }
        rowVC.sourceType = _sourceType
    }
    
}

extension ImagesRow {
    
    //MARK: Helpers
    
    func createOptionForAlertController(_ alertController: UIAlertController, sourceType: ImageRowSourceTypes) {
        guard let pickerSourceType = UIImagePickerControllerSourceType(rawValue: sourceType.imagePickerControllerSourceTypeRawValue), sourceTypes.contains(sourceType) else { return }
        let option = UIAlertAction(title: NSLocalizedString(sourceType.localizedString, comment: ""), style: .default, handler: { [weak self] _ in
            self?.displayImagePickerController(pickerSourceType)
        })
        alertController.addAction(option)
    }
    
    func createOptionsForAlertController(_ alertController: UIAlertController) {
        createOptionForAlertController(alertController, sourceType: .camera)
        createOptionForAlertController(alertController, sourceType: .photoLibrary)
        createOptionForAlertController(alertController, sourceType: .savedPhotosAlbum)
    }
}

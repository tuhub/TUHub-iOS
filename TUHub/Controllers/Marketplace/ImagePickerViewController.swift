//
//  ImagePickerViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 4/7/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

//import Eureka
//import Foundation
//
///// Selector Controller used to pick an image
//open class ImagePickerViewController : UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    /// The row that pushed or presented this controller
//    public var row: RowOf<UIImage>!
//    
//    /// A closure to be called when the controller disappears.
//    public var onDismissCallback : ((UIViewController) -> ())?
//    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        delegate = self
//    }
//    
//    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        (row as? ImagesPickerRow)?.imageURLS.insert(info[UIImagePickerControllerReferenceURL] as? URL)
//        row.value = info[UIImagePickerControllerOriginalImage] as? UIImage
//        onDismissCallback?(self)
//    }
//    
//    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
//        onDismissCallback?(self)
//    }
//}

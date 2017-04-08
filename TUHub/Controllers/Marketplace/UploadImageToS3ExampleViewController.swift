//
//  UploadImageToS3ExampleViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3

class UploadImageToS3ExampleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var image: UIImage!
    var selectedImageUrl: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressUpload(_ sender: Any) {
        uploadImage()
    }
    
    @IBAction func didPressImportImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func generateImageUrl(fileName: String) -> NSURL {
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        let data = UIImageJPEGRepresentation(image, 0.3)
        do {
            try data!.write(to: fileURL as URL)
        } catch {
            print(error)
        }
        
        return fileURL
    }
    
    func remoteImageWithUrl(fileName: String){
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        do {
            try FileManager.default.removeItem(at: fileURL as URL)
        } catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        selectedImageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL
        
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage

        let imageName = selectedImageUrl?.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL = NSURL(fileURLWithPath: documentDirectory)
        let localPath = photoURL.appendingPathComponent(imageName!)
        print(localPath!)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: S3 Image Upload
    func uploadImage() {
        
        var localFileName: String?
        
        if let imageToUpload =  selectedImageUrl {
            localFileName = imageToUpload.lastPathComponent
        }
        
        if localFileName == nil {
            return
        }
        
        // Configure AWS Cognito Credentials
        let myIdentityPoolId = "us-east-1:bbb7121f-0ae4-4089-9165-55cd2ea4663d"
        
        let credentialsProvider:AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType:AWSRegionType.USEast1, identityPoolId: myIdentityPoolId)
        
        let configuration = AWSServiceConfiguration(region:AWSRegionType.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Set up AWS Transfer Manager Request
        let folderName = "testImage"
        let S3BucketName = "tumobilemarketplace/\(folderName)"
        let remoteName = localFileName!
//        let ext = "jpeg"
//        let localFileName = "Nature" // local file name here
//        let remoteName = localFileName + "." + ext
        //random filename
        //let fileName = NSUUID().UUIDString + "." + ext
        
//        let imageURL = Bundle.main.url(forResource: localFileName, withExtension: ext)!
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        //uploadRequest?.body = imageURL
        uploadRequest?.body = generateImageUrl(fileName: remoteName) as URL
        //Image name
        uploadRequest?.key = remoteName
        // Bucket name
        uploadRequest?.bucket = S3BucketName
        //uploadRequest?.contentType = "image/" + ext
        uploadRequest?.contentType = "image/jpeg"
        
        let transferManager = AWSS3TransferManager.default()
        
        // Perform file upload
        transferManager.upload(uploadRequest!).continueWith(block: { (task:AWSTask) -> Any? in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            //            if let exception = task.exception {
            //                print("Upload failed with exception (\(exception))")
            //            }
            
            if task.result != nil {
                
                let s3URL = URL(string: "https://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest!.key!)")!
                print("Uploaded to:\n\(s3URL)")
                
                // Read uploaded image and display in a view
                let imageData = NSData(contentsOf: s3URL as URL)
                
                if let downloadedImageData = imageData
                {
                    DispatchQueue.main.async {
                        let image = UIImage(data: downloadedImageData as Data)
                        let myImageView:UIImageView = UIImageView()
                        myImageView.frame = CGRect(x:16, y:129, width:343, height:215)
                        myImageView.image = image
                        myImageView.contentMode = UIViewContentMode.scaleAspectFit
                        
                        self.view.addSubview(myImageView)
                    }
                }
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        })
        
    }
    
}


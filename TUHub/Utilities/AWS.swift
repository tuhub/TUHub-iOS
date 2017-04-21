//
//  AWS.swift
//  TUHub
//
//  Created by Connor Crawford on 4/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import AWSS3

final class AWS {
    static let bucket = "tumobilemarketplace"
    static let bucketURL = "https://tumobilemarketplace.s3.amazonaws.com"
    
    static func upload(folder: String, images: [UIImage], _ responseHandler: @escaping (Error?)->Void) { // -> String {
        
//        let folder = ProcessInfo.processInfo.globallyUniqueString
        let bucket = AWS.bucket + "/" + folder
        let ext = "jpeg"
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            for (i, image) in images.enumerated() {
                if let url = AWS.writeImageToFile(image) {
                    let file = "\(i)"
                    
                    // build an upload request
                    guard let uploadRequest = AWSS3TransferManagerUploadRequest() else {
                        responseHandler(nil)
                        return
                    }
                    uploadRequest.body = url
                    uploadRequest.key = file + "." + ext
                    uploadRequest.bucket = bucket
                    uploadRequest.contentType = "image/" + ext
                    
                    // upload
                    let transferManager = AWSS3TransferManager.default()
                    transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject! in
                        
                        if let error = task.error {
                            print("Upload failed ❌ (\(error))")
                        }
                        
                        if task.result != nil {
                            let s3URL = URL(string: "http://s3.amazonaws.com/\(bucket)/\(uploadRequest.key!)")!
                            print("Uploaded to:\n\(s3URL)")
                        }
                        else {
                            print("Unexpected empty result.")
                        }
                        
                        responseHandler(task.error)
                        
                        return nil
                    }
                }
            }
        }
        
//        return folder
    }
    
    private static func writeImageToFile(_ image: UIImage) -> URL? {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().uuidString
        
        // This returns a URL? even though it is an NSURL class method
        guard let url = NSURL.fileURL(withPathComponents: [directory, fileName]) else { return nil }
        
        // save image to URL
        do {
            try UIImageJPEGRepresentation(image, 0.5)?.write(to: url)
        } catch {
            log.error("Unable to write image to temp directory: \(error)")
            return nil
        }
        
        return url
        
    }

}

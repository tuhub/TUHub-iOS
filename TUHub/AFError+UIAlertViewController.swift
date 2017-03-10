//
//  AFError+UIAlertViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/10/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import Alamofire

extension AFError {
    
    func displayAlertController(from viewController: UIViewController) {
        
        let error = self
        var alertController: UIAlertController?
        
        switch error {
        case .invalidURL(let url):
            print("Invalid URL: \(url) - \(error.localizedDescription)")
        case .parameterEncodingFailed(let reason):
            print("Parameter encoding failed: \(error.localizedDescription)")
            print("Failure Reason: \(reason)")
        case .multipartEncodingFailed(let reason):
            print("Multipart encoding failed: \(error.localizedDescription)")
            print("Failure Reason: \(reason)")
        case .responseValidationFailed(let reason):
            print("Response validation failed: \(error.localizedDescription)")
            print("Failure Reason: \(reason)")
            
            switch reason {
            case .dataFileNil, .dataFileReadFailed:
                print("Downloaded file could not be read")
            case .missingContentType(let acceptableContentTypes):
                print("Content Type Missing: \(acceptableContentTypes)")
            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
            case .unacceptableStatusCode(let code):
                print("Response status code was unacceptable: \(code)")
            }
        case .responseSerializationFailed(let reason):
            print("Response serialization failed: \(error.localizedDescription)")
            print("Failure Reason: \(reason)")
            
            if viewController is SignInViewController {
                alertController = UIAlertController(title: "Unable to Sign In",
                                                    message: "Invalid username/password. Please try again.",
                                                    preferredStyle: UIAlertControllerStyle.alert)
                alertController?.addAction(UIAlertAction(title: "Done",
                                                         style: .default,
                                                         handler: nil))
            }
        }
        
        print("Underlying error: \(error.underlyingError)")
        
        if let alertController = alertController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
}

//
//  UILabel+NSAttributedString.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// Asynchronously parses a string containing HTML into an NSAttributed string matching
    /// the label's designated style
    func setAttrbitedText(fromHTMLString htmlString: String, _ completionHandler: (() -> Void)?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to parse HTML to NSAttributedString
            do {
                let modifiedFont = NSString(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>" as NSString, htmlString) as String
                
                //process collection values
                let attrStr = try NSAttributedString(
                    data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
                    options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
                    documentAttributes: nil)
                
                debugPrint(attrStr)
                DispatchQueue.main.async {
                    self.attributedText = attrStr
                    completionHandler?()
                }
                
            } catch {
                log.error("Error: Unable to parse HTML to NSAttributedString.")
            }
        }
        
    }
    
    /// Asynchronously parses a string containing HTML into an NSAttributed string matching
    /// the label's designated style
    func setAttrbitedText(fromHTMLString htmlString: String) {
        
        // Attempt to parse HTML to NSAttributedString
        do {
            let modifiedFont = NSString(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>" as NSString, htmlString) as String
            
            //process collection values
            let attrStr = try NSAttributedString(
                data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
            
            debugPrint(attrStr)
            self.attributedText = attrStr
            
        } catch {
            log.error("Error: Unable to parse HTML to NSAttributedString.")
        }
        
    }
    
}

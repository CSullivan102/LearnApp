//
//  ShareViewController.swift
//  Share
//
//  Created by Christopher Sullivan on 8/23/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    var shareURL: NSURL?
    var shareURLTitle: String?
    
    override func presentationAnimationDidFinish() {
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
            attachment = item.attachments?.first as? NSItemProvider
        else { return }
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (urlProvider, error) -> Void in
                if let url = urlProvider as? NSURL {
                    self.shareURL = url
                    self.shareURLTitle = item.attributedTitle?.string
                }
            })
        }
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

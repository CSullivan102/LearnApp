//
//  PocketAuthModalController.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/8/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit

class PocketAuthModalController: UIViewController, PocketAPISettable, UIViewControllerHeightRequestable {
    
    var pocketAPI: PocketAPI!
    var completionHandler: ((Bool) -> ())?
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        closeModal(false)
    }
    
    @IBAction func authenticateButtonPressed(sender: UIButton) {
        pocketAPI.authenticate {
            self.closeModal(true)
        }
    }
    
    private func closeModal(success: Bool) {
        if let completionHandler = completionHandler {
            completionHandler(success)
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func preferredHeight() -> CGFloat {
        return 180
    }
}

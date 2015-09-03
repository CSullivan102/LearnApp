//
//  CreateTopicTransitioningDelegate.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/31/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit

public class CreateTopicTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CreateTopicPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CreateTopicAnimator()
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CreateTopicDismissalAnimator()
    }
}

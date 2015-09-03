//
//  SlidingTransitionPresentationController.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/2/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit

public class SlidingTransitionPresentationController: UIPresentationController {
    
    public override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let presentingVC = presentingViewController as? SlidingTransitionViewController,
            containerView = containerView
            else { print("not a slidingtransition VC"); return super.frameOfPresentedViewInContainerView() }
        
        let originalView = presentingVC.slidingViewForTransition()
        let convertedRect = containerView.convertRect(originalView.frame, fromView: originalView.superview)
        return convertedRect
    }
    
    public override func containerViewWillLayoutSubviews() {
        guard let presentedView = presentedView()
        else { return super.containerViewWillLayoutSubviews() }
        
        presentedView.frame = frameOfPresentedViewInContainerView()
    }
}

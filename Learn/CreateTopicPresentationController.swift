//
//  CreateTopicPresentationController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/31/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit

class CreateTopicPresentationController: UIPresentationController {
    
    private let dimmingView = UIView()
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView
        else { return }
        
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            context in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            context in
            self.dimmingView.alpha = 0.0
        }, completion: {
            context in
            self.dimmingView.removeFromSuperview()
        })
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let containerView = containerView
        else { return CGRect(x: 0, y: 0, width: 0, height: 0) }
        
        let modalHeight: CGFloat = 135.0
        let insetBounds = containerView.bounds.insetBy(dx: 30, dy: 0)
        let yCoord = insetBounds.height / 2 - modalHeight
        
        return CGRect(x: insetBounds.origin.x, y: yCoord, width: insetBounds.width, height: modalHeight)
    }
    
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView,
            presentedView = presentedView()
        else { return }
        
        dimmingView.frame = containerView.bounds
        presentedView.frame = frameOfPresentedViewInContainerView()
    }
}

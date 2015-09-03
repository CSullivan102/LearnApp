//
//  CreateTopicSlidingAnimator.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/31/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit

public class CreateTopicSlidingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presenting: Bool
    
    private let duration: NSTimeInterval = 0.6
    private let damping: CGFloat = 1.0
    private let initialSprintVelocity: CGFloat = 0.0
    private let delay: NSTimeInterval = 0.0
    private let animationOptions = UIViewAnimationOptions()
    
    required public init(presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let presentingViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? SlidingTransitionViewController
            else {
                if let presentingView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
                    print("\(presentingView.frame)")
                    presentingView.hidden = true
                } else {
                    print("and no presenting?")
                }
                print("no presenting view?"); return
        }
        guard let presentedView = transitionContext.viewForKey(UITransitionContextToViewKey) else { fatalError("Couldn't get to view") }
        guard let presentedViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { fatalError("Couldn't get to VC") }
        
        guard let containerView = transitionContext.containerView() else { return }
        
        let presentingView = presentingViewController.slidingViewForTransition()
        let presentingViewSnapshot = presentingView.snapshotViewAfterScreenUpdates(false)

        let finalToFrame = transitionContext.finalFrameForViewController(presentedViewController)
        
        containerView.addSubview(presentingViewSnapshot)
        containerView.addSubview(presentedView)
        
        presentingViewSnapshot.frame = finalToFrame
        presentingViewSnapshot.transform = CGAffineTransformIdentity
        presentedView.frame = finalToFrame
        presentedView.transform = CGAffineTransformMakeTranslation(presentedView.frame.size.width, 0)
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: initialSprintVelocity, options: animationOptions, animations: { () -> Void in
            presentingViewSnapshot.transform = CGAffineTransformMakeTranslation(-presentingViewSnapshot.frame.size.width, 0)
            presentedView.transform = CGAffineTransformIdentity
        }) { (_) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

public protocol SlidingTransitionViewController {
    func slidingViewForTransition() -> UIView
}
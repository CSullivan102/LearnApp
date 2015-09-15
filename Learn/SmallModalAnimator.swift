//
//  SmallModalAnimator.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/31/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit

public class SmallModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: NSTimeInterval = 0.6
    private let damping: CGFloat = 0.9
    private let initialSpringVelocity: CGFloat = 10.0
    private let delay: NSTimeInterval = 0.0
    private let animationOptions = UIViewAnimationOptions.CurveEaseOut
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedView = transitionContext.viewForKey(UITransitionContextToViewKey) else {
            return
        }
        
        let presentedViewCenter = presentedView.center
        presentedView.center = CGPoint(x: presentedViewCenter.x, y: -presentedView.bounds.size.height)

        transitionContext.containerView()?.addSubview(presentedView)
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
                             delay: delay,
            usingSpringWithDamping: damping,
             initialSpringVelocity: initialSpringVelocity,
                           options: animationOptions,
                        animations: {
            presentedView.center = presentedViewCenter
        }) {
            _ in
            self.finishTransition(transitionContext)
        }
    }
    
    private func finishTransition(transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    }
}

public class SmallModalDismissalAnimator: SmallModalAnimator {
    
    override public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedView = transitionContext.viewForKey(UITransitionContextFromViewKey) else {
            return
        }
        
        UIView.animateWithDuration(duration,
                             delay: delay,
            usingSpringWithDamping: damping,
             initialSpringVelocity: initialSpringVelocity,
                           options: animationOptions,
                        animations: {
            presentedView.center = CGPoint(x: presentedView.center.x, y: -presentedView.bounds.size.height)
        }) { _ in
            presentedView.removeFromSuperview()
            self.finishTransition(transitionContext)
        }
    }
}

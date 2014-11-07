//
//  ShowImageAnimator.swift
//  HipsterPhoto
//
//  Created by William Richman on 10/22/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

class ShowImageAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var origin : CGRect?
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as PhotoFrameworkViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as SinglePhotoViewController
        
        let containerView = transitionContext.containerView()
        
        toViewController.view.frame = self.origin!
        toViewController.imageView.frame = toViewController.view.bounds
        
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            toViewController.view.frame = fromViewController.view.frame
            toViewController.imageView.frame = fromViewController.view.bounds
            fromViewController.view.alpha = 0.0
        }) { (finished) -> Void in
            transitionContext.completeTransition(finished)
        }
        
    }
}

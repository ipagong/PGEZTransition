//
//  PGTransformPushTransition.swift
//  PGEZTransition
//
//  Created by ipagong on 11/02/2019.
//

import UIKit

@objc
open class PGTransformPushTransition : PGTransformTransition, UINavigationControllerDelegate {
    
    var navigation: UINavigationController? {
        return self.target?.navigationController
    }
    
    override open func showOpenAction() {
        guard let nv = self.navigation else { return }
        guard let vc = self.showing    else { return }
        guard canShow      == true     else { return }
        guard enableShow   == true     else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true

        nv.delegate = self
        nv.transitioningDelegate = self
        nv.pushViewController(vc, animated: true)
    }
    
    override open func hideAction() {
        guard let nv = self.navigation else { return }
        guard let vc = self.showing    else { return }
        guard canHide      == true     else { return }
        guard enableHide   == true     else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        
        nv.delegate = self
        nv.transitioningDelegate = self
        nv.popViewController(animated: true)
    }
    
    @objc
    override open func showTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        guard let nv = self.navigation else { return }
        guard let vc = self.showing    else { return }
        guard canShow      == true     else { return }
        guard enableShow   == true     else { return }
        guard isShowed     == false    else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        self.setShowCompletion(block: completion)
        
        nv.delegate = self
        nv.transitioningDelegate = self
        nv.pushViewController(vc, animated: animated)
    }

    @objc
    override open func hideTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        guard let nv = self.navigation else { return }
        guard let vc  = self.showing   else { return }
        guard canHide      == true     else { return }
        guard enableHide   == true     else { return }
        guard isShowed     == true     else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart      = true
        self.setHideCompletion(block: completion)
        
        nv.delegate = self
        nv.transitioningDelegate = self
        nv.popViewController(animated: true)
    }
    
    override open func transitionInitalized() {
        self.navigation?.delegate = self
        self.target?.transitioningDelegate = self
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.hasInteraction == true ? self : nil)
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        func findTransition() -> PGTransformPushTransition? {
            switch operation {
            case .push:
                return fromVC.transitioningDelegate as? PGTransformPushTransition
            case .pop:
                return toVC.transitioningDelegate   as? PGTransformPushTransition
            default:    return nil
            }
        }
        
        guard let transition = findTransition() else { return nil }
        
        self.navigation?.delegate = transition
        self.navigation?.transitioningDelegate = transition
        
        return transition
    }
}

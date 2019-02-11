//
//  PGTransformPresentTransition.swift
//  PGEZTransition
//
//  Created by ipagong on 11/02/2019.
//

import UIKit

class PGTransformPresentTransition: PGTransformTransition {
    
    @objc
    override open func showOpenAction() {
        guard let vc = self.showing    else { return }
        guard canShow      == true     else { return }
        guard enableShow   == true     else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        
        vc.transitioningDelegate = self
        
        self.target?.present(vc, animated: true, completion: nil)
    }
    
    @objc
    override open func hideAction() {
        guard let vc = self.showing    else { return }
        guard canHide      == true     else { return }
        guard enableHide   == true     else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        
        vc.dismiss(animated: true, completion: nil)
    }
    
    
    @objc
    override open func showTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        guard let vc = self.showing    else { return }
        guard canShow      == true     else { return }
        guard enableShow   == true     else { return }
        guard isShowed     == false    else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        vc.transitioningDelegate  = self
        self.target?.present(vc, animated: animated) { completion?(true) }
    }
    
    @objc
    override open func hideTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        guard let vc = self.showing    else { return }
        guard canHide      == true     else { return }
        guard enableHide   == true     else { return }
        guard isShowed     == true     else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart      = true
        vc.transitioningDelegate = self
        
        vc.dismiss(animated: animated) { completion?(true) }
    }
}

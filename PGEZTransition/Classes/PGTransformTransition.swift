//
//  PGTransformTransition.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 12..
//  Copyright © 2018년 iPagong. All rights reserved.
//


import UIKit

public typealias PGTransformCompleted = (Bool) -> ()
public typealias PGTransformChecked   = (PGTransformTransition) -> (Bool)

@objc
open class PGTransformTransition: UIPercentDrivenInteractiveTransition,
UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    public var presentBlock:PGTransformCompleted?
    public var dismissBlock:PGTransformCompleted?
    
    public var canPresentBlock:PGTransformChecked?
    public var canDismissBlock:PGTransformChecked?
    
    public var canPresent:Bool { return self.canPresentBlock?(self) ?? true }
    public var canDismiss:Bool { return self.canDismissBlock?(self) ?? true }
    
    public var enablePresent:Bool = true
    public var enableDismiss:Bool = true
    
    public var presentDuration:TimeInterval = 0.5
    public var dismissDuration:TimeInterval = 0.5
    
    public weak var target:UIViewController?
    public weak var presenting:UIViewController? {
        willSet {
            guard self.isPresented == false else { return }
            guard self.presenting?.view.gestureRecognizers?.contains(self.dismissGesture) == true else { return }
            self.presenting?.view.removeGestureRecognizer(self.dismissGesture)
        }
        
        didSet {
            guard self.isPresented == false else {
                self.presenting = oldValue
                return
            }
            self.presenting?.view.addGestureRecognizer(self.dismissGesture)
        }
    }
    
    private weak var current:UIViewController?
    
    private var isPresented:Bool { return current != target }
    
    private var hasInteraction:Bool = false
    private var didActionStart:Bool = false
    private var beganPanPoint:CGPoint = .zero
    private var maxDistance:CGFloat { return (self.target?.view.bounds.width ?? 320.0) / 2 }

    @objc
    override init() { super.init() }
    
    @objc
    public init(target:UIViewController) {
        super.init()
        
        self.target  = target
        self.current = target
        
        target.view.addGestureRecognizer(self.presentGesture)
    }
    
    @objc
    public init(target:UIViewController, presenting:UIViewController) {
        super.init()
        
        self.target = target
        target.view.addGestureRecognizer(self.presentGesture)
        
        self.presenting = presenting
        presenting.view.setNeedsLayout()
        presenting.view.addGestureRecognizer(self.dismissGesture)
        
        self.current = target
    }
    
    lazy public var presentGesture:UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onPresentWith(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    lazy public var dismissGesture:UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onDismissWith(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    deinit {
        self.target     = nil
        self.presenting = nil
    }
    
    @objc public func onPresentWith(gesture:UIPanGestureRecognizer) {
        guard let _ = self.presenting else { return }
        guard canPresent    == true   else { return }
        guard enablePresent == true   else { return }
        guard isPresented   == false  else { return }
        
        guard let window = target?.view.window else { return }
        
        let location = gesture.location(in: window)
        let velocity = gesture.velocity(in: window)
        
        switch gesture.state {
        case .began:
            
            self.beganPanPoint = location
            self.hasInteraction = true
            
        case .changed:
            let percentage = (self.beganPanPoint.x - location.x) / maxDistance
            
            PGLogger.debug("[PRESENT PERCENTAGE] \(percentage)")
            
            if percentage > 0 {
                self.presentOpenAction()
                self.update(percentage)
            } else {
                self.cancel()
            }
            
        case .ended:
            guard self.hasInteraction == true else {
                return
            }
            
            if velocity.x < 0 {
                self.finish()
            } else {
                self.cancel()
            }
            
            self.hasInteraction = false
            self.beganPanPoint  = .zero
        default:
            break
        }
    }
    
    @objc public func onDismissWith(gesture:UIPanGestureRecognizer) {
        guard let _ = presenting    else { return }
        guard canDismiss    == true else { return }
        guard enableDismiss == true else { return }
        guard isPresented   == true else { return }
        
        guard let window = presenting?.view.window else { return }
        
        let location = gesture.location(in: window)
        let velocity = gesture.velocity(in: window)
        
        switch gesture.state {
        case .began:
            
            self.beganPanPoint = location
            self.hasInteraction = true
            
        case .changed:
            
            guard self.beganPanPoint.equalTo(.zero) == false else { return }
            
            let percentage = (location.x - self.beganPanPoint.x) / maxDistance
            
            PGLogger.debug("[DISMISS PERCENTAGE] \(percentage)")
            
            if percentage > 0 {
                self.dismissAction()
                self.update(percentage)
            } else {
                self.cancel()
            }
            
        case .ended:
            guard self.beganPanPoint.equalTo(.zero) == false else { return }
            
            guard hasInteraction == true else {
                return
            }
            
            if velocity.x > 0 {
                self.finish()
            } else {
                self.cancel()
            }
            
            self.hasInteraction = false
            self.beganPanPoint  = .zero
            
        default:
            break
        }
    }
    
    private func presentAnimation(from:UIViewController, to:UIViewController, container:UIView, context: UIViewControllerContextTransitioning) {
        let fromViewBackgroundColor = from.view.backgroundColor
        from.view.backgroundColor = .clear
        
        container.backgroundColor = fromViewBackgroundColor
        container.addSubview(to.view)
        container.addSubview(from.view)
        
        var fromViews = from.view.subviews.compactMap { $0 as? (PGTransformable & UIView) }
        var toViews   = to.view.subviews.compactMap   { $0 as? (PGTransformable & UIView) }
        (from.view as? (PGTransformable & UIView)).map { fromViews.append($0) }
        (to.view   as? (PGTransformable & UIView)).map { toViews.append($0)   }
        
        fromViews.forEach { view in
            view.alpha     = 1.0
            view.transform = CGAffineTransform.identity
            PGLogger.debug("[Present Initialize] fromView transform : \(view.endTransform), alpha \(view.endAlpha)")
        }
        
        toViews.forEach { view in
            view.alpha     = view.startAlpha.value
            view.transform = view.startTransform.value
            PGLogger.debug("[Present Initialize] toView transform : \(view.startTransform), alpha \(view.startAlpha)")
        }
        
        from.viewWillDisappear(true)
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: context), delay: 0, options: [], animations: {
            
            fromViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: view.endAlpha.relatedStart, relativeDuration: view.endAlpha.relatedDuration, animations: {
                    view.alpha = view.endAlpha.value
                })
                
                UIView.addKeyframe(withRelativeStartTime: view.endTransform.relatedStart, relativeDuration: view.endTransform.relatedDuration, animations: {
                    view.transform = view.endTransform.value
                })
                PGLogger.debug("[Present AnimateKeyFrame] fromView transform : \(view.endTransform), alpha \(view.endAlpha)")
            }
            
            toViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: view.startAlpha.relatedStart, relativeDuration: view.startAlpha.relatedDuration, animations: {
                    view.alpha = 1.0
                })
                
                UIView.addKeyframe(withRelativeStartTime: view.startTransform.relatedStart, relativeDuration: view.startTransform.relatedDuration, animations: {
                    view.transform = CGAffineTransform.identity
                })
                PGLogger.debug("[Present AnimateKeyFrame] toViews transform : \(view.startTransform), alpha \(view.startAlpha)")
            }
            
            }, completion: { [unowned self] (_) in
                
                let canceled = context.transitionWasCancelled
                if canceled == true {
                    self.current = self.target
                    context.completeTransition(false)
                } else {
                    self.current = self.presenting
                    context.completeTransition(true)
                    from.viewDidDisappear(true)
                }
                
                fromViews.forEach { view in
                    PGLogger.debug("[Present Compeltion] fromView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }
                
                toViews.forEach { view in
                    PGLogger.debug("[Present Compeltion] toView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }

                from.view.backgroundColor = fromViewBackgroundColor
                self.presentBlock?(!canceled)
                self.didActionStart = false
        })
    }
    
    private func dismissAnimation(from:UIViewController, to:UIViewController, container:UIView, context: UIViewControllerContextTransitioning) {
        let fromViewBackgroundColor = from.view.backgroundColor
        from.view.backgroundColor = .clear
        container.backgroundColor = fromViewBackgroundColor
        container.addSubview(to.view)
        container.addSubview(from.view)
        
        var fromViews = from.view.subviews.compactMap { $0 as? (PGTransformable & UIView) }
        var toViews   = to.view.subviews.compactMap   { $0 as? (PGTransformable & UIView) }
        (from.view as? (PGTransformable & UIView)).map { fromViews.append($0) }
        (to.view   as? (PGTransformable & UIView)).map { toViews.append($0)   }
        
        to.viewWillAppear(true)
        
        fromViews.forEach { view in
            view.alpha     = 1.0
            view.transform = CGAffineTransform.identity
            PGLogger.debug("[Dismiss Initialize] fromView transform : \(view.startTransform), alpha \(view.startAlpha)")
        }
        toViews.forEach { view in
            view.alpha     = view.endAlpha.value
            view.transform = view.endTransform.value
            PGLogger.debug("[Dismiss Initialize] toView transform : \(view.endTransform), alpha \(view.endAlpha)")
        }
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: context), delay: 0, options: [], animations: {
            
            fromViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: view.startAlpha.relatedDuration, animations: {
                    view.alpha = view.startAlpha.value
                })
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: view.startTransform.relatedDuration, animations: {
                    view.transform = view.startTransform.value
                })
                PGLogger.debug("[Dismiss AnimateKeyFrame] fromView transform : \(view.startTransform), alpha \(view.startAlpha)")
            }
            
            toViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: view.endAlpha.relatedStart, relativeDuration: view.endAlpha.relatedDuration, animations: {
                    view.alpha = 1.0
                })
                UIView.addKeyframe(withRelativeStartTime: view.endTransform.relatedStart, relativeDuration: view.endTransform.relatedDuration, animations: {
                    view.transform = CGAffineTransform.identity
                })
                
                PGLogger.debug("[Dismiss AnimateKeyFrame] View transform : \(view.endTransform), alpha \(view.endAlpha)")
            }
            
            }, completion: { [unowned self] (_) in
                
                let canceled = context.transitionWasCancelled
                
                // do finished views
                
                if canceled == true {
                    self.current = self.presenting
                    context.completeTransition(false)
                } else {
                    self.current = self.target
                    context.completeTransition(true)
                    to.viewDidAppear(true)
                }
                
                fromViews.forEach { view in
                    PGLogger.debug("[Dismiss Compeltion] fromView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }
                
                toViews.forEach { view in
                    PGLogger.debug("[Dismiss Compeltion] toView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }
                
                from.view.backgroundColor = fromViewBackgroundColor
                self.dismissBlock?(!canceled)
                self.didActionStart = false
        })
    }
    
    private func presentOpenAction() {
        guard let vc = self.presenting else { return }
        guard canPresent      == true  else { return }
        guard enablePresent   == true  else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true

        vc.transitioningDelegate = self
        
        self.target?.present(vc, animated: true, completion: nil)
    }
    
    private func dismissAction() {
        guard let vc = self.presenting else { return }
        guard canDismiss      == true  else { return }
        guard enableDismiss   == true  else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        
        vc.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIVieControllerTransitioningDelegate methods
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.hasInteraction == true ? self : nil)
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.hasInteraction == true ? self : nil)
    }
    
    //MARK: - UIViewControllerAnimatedTransitioning methods
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresented ? dismissDuration : presentDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVc = transitionContext.viewController(forKey: .from) else { return }
        guard let toVc   = transitionContext.viewController(forKey: .to)   else { return }
        
        if (toVc === self.presenting) {
            self.presentAnimation(from: fromVc, to: toVc, container: transitionContext.containerView, context: transitionContext)
        } else {
            self.dismissAnimation(from: fromVc, to: toVc, container: transitionContext.containerView, context: transitionContext)
        }
    }
    
    //MARK: - public methods
    
    @objc public func setPresentCompletion(block:PGTransformCompleted?) { self.presentBlock = block }
    @objc public func setDismissCompletion(block:PGTransformCompleted?) { self.dismissBlock = block }
    
    @objc public func setCanPresentBlock(block:PGTransformChecked?) { self.canPresentBlock = block }
    @objc public func setCanDismissBlock(block:PGTransformChecked?) { self.canDismissBlock = block }
    
    @objc
    public func presentTransformViewController() {
        self.presentTransformViewController(animated: true, completion: nil)
    }
    
    @objc
    public func presentTransformViewController(animated:Bool) {
        self.presentTransformViewController(animated: animated, completion: nil)
    }
    
    @objc
    public func presentTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        guard let vc = self.presenting else { return }
        guard canPresent      == true  else { return }
        guard enablePresent   == true  else { return }
        guard isPresented     == false else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart = true
        vc.transitioningDelegate  = self
        self.target?.present(vc, animated: animated) { completion?(true) }
    }
    
    @objc
    public func dismissTransformViewController() {
        self.dismissTransformViewController(animated: true, completion: nil)
    }
    
    @objc
    public func dismissTransformViewController(animated:Bool) {
        self.dismissTransformViewController(animated: animated, completion: nil)
    }
    
    @objc
    public func dismissTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        guard let vc = self.presenting else { return }
        guard canDismiss      == true  else { return }
        guard enableDismiss   == true  else { return }
        guard isPresented     == true  else { return }
        guard percentComplete == 0     else { return }
        guard didActionStart  == false else { return }
        
        self.didActionStart      = true
        vc.transitioningDelegate = self
        
        vc.dismiss(animated: animated) { completion?(true) }
    }
    
    open override func update(_ percentComplete: CGFloat) {
        guard percentComplete >= 0.00 else { return }
        guard percentComplete <= 1.00 else { return }
        super.update(percentComplete)
    }
}

extension PGTransformTransition : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

typealias PGLogger = PGTransformTransition.Logger

extension PGTransformTransition {
    public static var debug:Bool = false
    
    public struct Logger {
        public static func debug(_ message: String) {
            guard PGTransformTransition.debug == true else { return }
            debugPrint("[PGTRANSFORM] \(message)")
        }
    }
}

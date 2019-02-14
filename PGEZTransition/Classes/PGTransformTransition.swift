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
    
    public var showBlock:PGTransformCompleted?
    public var hideBlock:PGTransformCompleted?
    
    public var canShowBlock:PGTransformChecked?
    public var canHideBlock:PGTransformChecked?
    
    public var canShow:Bool { return self.canShowBlock?(self) ?? true }
    public var canHide:Bool { return self.canHideBlock?(self) ?? true }
    
    public var enableShow:Bool = true
    public var enableHide:Bool = true
    
    public var showDuration:TimeInterval = 0.5
    public var hideDuration:TimeInterval = 0.5
    
    public weak var target:UIViewController?
    public weak var showing:UIViewController? {
        willSet {
            guard self.isShowed == false else { return }
            guard self.showing?.view.gestureRecognizers?.contains(self.hideGesture) == true else { return }
            self.showing?.view.removeGestureRecognizer(self.hideGesture)
        }
        
        didSet {
            guard self.isShowed == false else {
                self.showing = oldValue
                return
            }
            self.showing?.view.addGestureRecognizer(self.hideGesture)
        }
    }
    
    public weak var current:UIViewController?
    
    public var isShowed:Bool { return current != target }
    
    public var hasInteraction:Bool = false
    public var didActionStart:Bool = false
    public var beganPanPoint:CGPoint = .zero
    public var maxDistance:CGFloat { return (self.target?.view.bounds.width ?? 320.0) / 2 }

    @objc
    override init() { super.init() }
    
    @objc
    public init(target:UIViewController) {
        super.init()
        
        self.target  = target
        self.current = target
        
        target.view.addGestureRecognizer(self.showGesture)
        
        transitionInitalized()
    }
    
    @objc
    public init(target:UIViewController, showing:UIViewController) {
        super.init()
        
        self.target = target
        target.view.addGestureRecognizer(self.showGesture)
        
        self.showing = showing
        showing.view.setNeedsLayout()
        showing.view.addGestureRecognizer(self.hideGesture)
        
        self.current = target
        
        transitionInitalized()
    }

    lazy public var showGesture:UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onShowWith(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    lazy public var hideGesture:UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onHideWith(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    deinit {
        self.target  = nil
        self.showing = nil
    }
    
    @objc public func onShowWith(gesture:UIPanGestureRecognizer) {
        guard let _ = self.showing else { return }
        guard canShow    == true   else { return }
        guard enableShow == true   else { return }
        guard isShowed   == false  else { return }
        
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
                self.showOpenAction()
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
    
    @objc public func onHideWith(gesture:UIPanGestureRecognizer) {
        guard let _ = showing    else { return }
        guard canHide    == true else { return }
        guard enableHide == true else { return }
        guard isShowed   == true else { return }
        
        guard let window = showing?.view.window else { return }
        
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
                self.hideAction()
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
    
    private func showAnimation(from:UIViewController, to:UIViewController, container:UIView, context: UIViewControllerContextTransitioning) {
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
            PGLogger.debug("[Show Initialize] fromView transform : \(view.endTransform), alpha \(view.endAlpha)")
        }
        
        toViews.forEach { view in
            view.alpha     = view.startAlpha.value
            view.transform = view.startTransform.value
            PGLogger.debug("[Show Initialize] toView transform : \(view.startTransform), alpha \(view.startAlpha)")
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
                PGLogger.debug("[Show AnimateKeyFrame] fromView transform : \(view.endTransform), alpha \(view.endAlpha)")
            }
            
            toViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: view.startAlpha.relatedStart, relativeDuration: view.startAlpha.relatedDuration, animations: {
                    view.alpha = 1.0
                })
                
                UIView.addKeyframe(withRelativeStartTime: view.startTransform.relatedStart, relativeDuration: view.startTransform.relatedDuration, animations: {
                    view.transform = CGAffineTransform.identity
                })
                PGLogger.debug("[Show AnimateKeyFrame] toViews transform : \(view.startTransform), alpha \(view.startAlpha)")
            }
            
            }, completion: { [unowned self] (_) in
                
                let canceled = context.transitionWasCancelled
                if canceled == true {
                    self.current = from
                    context.completeTransition(false)
                } else {
                    self.current = to
                    context.completeTransition(true)
                    from.viewDidDisappear(true)
                }
                
                fromViews.forEach { view in
                    PGLogger.debug("[Show Compeltion] fromView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }
                
                toViews.forEach { view in
                    PGLogger.debug("[Show Compeltion] toView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }

                from.view.backgroundColor = fromViewBackgroundColor
                self.showBlock?(!canceled)
                self.didActionStart = false
                
                self.transitionCompletion(self.current)
        })
    }
    
    private func hideAnimation(from:UIViewController, to:UIViewController, container:UIView, context: UIViewControllerContextTransitioning) {
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
            PGLogger.debug("[Hide Initialize] fromView transform : \(view.startTransform), alpha \(view.startAlpha)")
        }
        toViews.forEach { view in
            view.alpha     = view.endAlpha.value
            view.transform = view.endTransform.value
            PGLogger.debug("[Hide Initialize] toView transform : \(view.endTransform), alpha \(view.endAlpha)")
        }
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: context), delay: 0, options: [], animations: {
            
            fromViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: view.startAlpha.relatedDuration, animations: {
                    view.alpha = view.startAlpha.value
                })
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: view.startTransform.relatedDuration, animations: {
                    view.transform = view.startTransform.value
                })
                PGLogger.debug("[Hide AnimateKeyFrame] fromView transform : \(view.startTransform), alpha \(view.startAlpha)")
            }
            
            toViews.forEach { view in
                UIView.addKeyframe(withRelativeStartTime: view.endAlpha.relatedStart, relativeDuration: view.endAlpha.relatedDuration, animations: {
                    view.alpha = 1.0
                })
                UIView.addKeyframe(withRelativeStartTime: view.endTransform.relatedStart, relativeDuration: view.endTransform.relatedDuration, animations: {
                    view.transform = CGAffineTransform.identity
                })
                
                PGLogger.debug("[Hide AnimateKeyFrame] View transform : \(view.endTransform), alpha \(view.endAlpha)")
            }
            
            }, completion: { [unowned self] (_) in
                
                let canceled = context.transitionWasCancelled
                
                // do finished views
                
                if canceled == true {
                    self.current = from
                    context.completeTransition(false)
                } else {
                    self.current = to
                    context.completeTransition(true)
                    to.viewDidAppear(true)
                }
                
                fromViews.forEach { view in
                    PGLogger.debug("[Hide Compeltion] fromView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }
                
                toViews.forEach { view in
                    PGLogger.debug("[Hide Compeltion] toView")
                    view.alpha     = 1.0
                    view.transform = CGAffineTransform.identity
                }
                
                from.view.backgroundColor = fromViewBackgroundColor
                self.hideBlock?(!canceled)
                self.didActionStart = false
                
                self.transitionCompletion(self.current)
        })
    }
    
    //MARK: - UIVieControllerTransitioningDelegate methods
    
    public func animationController(forShowed showed: UIViewController, showing: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forHideed hideed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForShowation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.hasInteraction == true ? self : nil)
    }
    
    public func interactionControllerForHideal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.hasInteraction == true ? self : nil)
    }
    
    //MARK: - UIViewControllerAnimatedTransitioning methods
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isShowed ? hideDuration : showDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = transitionContext.viewController(forKey: .from) else { return }
        guard let toVc   = transitionContext.viewController(forKey: .to)   else { return }
        
        if (toVc === self.showing) {
            self.showAnimation(from: fromVc, to: toVc, container: transitionContext.containerView, context: transitionContext)
        } else {
            self.hideAnimation(from: fromVc, to: toVc, container: transitionContext.containerView, context: transitionContext)
        }
    }
    
    //MARK: - public methods
    
    @objc public func setShowCompletion(block:PGTransformCompleted?) { self.showBlock = block }
    @objc public func setHideCompletion(block:PGTransformCompleted?) { self.hideBlock = block }
    
    @objc public func setCanShowBlock(block:PGTransformChecked?) { self.canShowBlock = block }
    @objc public func setCanHideBlock(block:PGTransformChecked?) { self.canHideBlock = block }
    
    @objc
    public func showTransformViewController() {
        self.showTransformViewController(animated: true, completion: nil)
    }
    
    @objc
    public func showTransformViewController(animated:Bool) {
        self.showTransformViewController(animated: animated, completion: nil)
    }

    @objc
    public func hideTransformViewController() {
        self.hideTransformViewController(animated: true, completion: nil)
    }
    
    @objc
    public func hideTransformViewController(animated:Bool) {
        self.hideTransformViewController(animated: animated, completion: nil)
    }
    
    open override func update(_ percentComplete: CGFloat) {
        guard percentComplete >= 0.00 else { return }
        guard percentComplete <= 1.00 else { return }
        super.update(percentComplete)
    }
}

extension PGTransformTransition {
    @objc
    public func showOpenAction() {
        // do override
    }
    
    @objc
    public func hideAction() {
        // do override
    }
    
    @objc
    public func showTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        // do override
    }
    
    @objc
    public func hideTransformViewController(animated:Bool, completion:PGTransformCompleted?) {
        // do override
    }
    
    @objc
    public func transitionInitalized() {
        // do override
    }
    
    @objc
    public func transitionCompletion(_ vc:UIViewController?) {
        // do override
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

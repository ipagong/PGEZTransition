//
//  PGTransformItemViews.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 12..
//  Copyright © 2018년 iPagong. All rights reserved.
//

import UIKit

@objc
public protocol PGTransformable : class {
    @objc var startTransform  : PGTransformValue { get set }
    @objc var endTransform    : PGTransformValue { get set }
    @objc var startAlpha      : PGTransformAlpha { get set }
    @objc var endAlpha        : PGTransformAlpha { get set }
}

// MARK: - for swift project

extension PGTransformable where Self : UIView {
    @discardableResult
    public func setStartTransform(_ item:PGTransformValue.Item, start:Double, duration:Double) -> Self {
        self.startTransform = PGTransformValue(item: item, relatedStart: start, relatedDuration: duration)
        return self
    }
    
    @discardableResult
    public func setStartTransformValue(_ value:PGTransformValue) -> Self {
        self.startTransform = value
        return self
    }
    
    @discardableResult
    public func setEndTransform(_ item:PGTransformValue.Item, start:Double, duration:Double) -> Self {
        self.endTransform = PGTransformValue(item: item, relatedStart: start, relatedDuration: duration)
        return self
    }
    
    @discardableResult
    public func setEndTransformValue(_ value:PGTransformValue) -> Self {
        self.endTransform = value
        return self
    }
    
    @discardableResult
    public func setStartAlpha(_ value:CGFloat, start:Double, duration:Double) -> Self {
        self.startAlpha = PGTransformAlpha(value: value, relatedStart: start, relatedDuration: duration)
        return self
    }
    
    @discardableResult
    public func setEndAlpha(_ value:CGFloat, start:Double, duration:Double) -> Self {
        self.endAlpha = PGTransformAlpha(value: value, relatedStart: start, relatedDuration: duration)
        return self
    }
}

// MARK: - SimpleTransformViews

open class PGTransformImageView : UIImageView, PGTransformable {
    public var startTransform  : PGTransformValue = PGTransformValue()
    public var endTransform    : PGTransformValue = PGTransformValue()
    public var startAlpha      : PGTransformAlpha = PGTransformAlpha()
    public var endAlpha        : PGTransformAlpha = PGTransformAlpha()
}

open class PGTransformButton : UIButton, PGTransformable {
    public var startTransform  : PGTransformValue = PGTransformValue()
    public var endTransform    : PGTransformValue = PGTransformValue()
    public var startAlpha      : PGTransformAlpha = PGTransformAlpha()
    public var endAlpha        : PGTransformAlpha = PGTransformAlpha()
}

open class PGTransformView : UIView, PGTransformable {
    public var startTransform  : PGTransformValue = PGTransformValue()
    public var endTransform    : PGTransformValue = PGTransformValue()
    public var startAlpha      : PGTransformAlpha = PGTransformAlpha()
    public var endAlpha        : PGTransformAlpha = PGTransformAlpha()
}

open class PGTransformLabel : UILabel, PGTransformable {
    public var startTransform  : PGTransformValue = PGTransformValue()
    public var endTransform    : PGTransformValue = PGTransformValue()
    public var startAlpha      : PGTransformAlpha = PGTransformAlpha()
    public var endAlpha        : PGTransformAlpha = PGTransformAlpha()
}

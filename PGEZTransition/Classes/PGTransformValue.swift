//
//  PGTransformValue.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 13..
//  Copyright © 2018년 iPagong. All rights reserved.
//

import Foundation

@objc
open class PGTransformValue : NSObject {
    var value:CGAffineTransform     = CGAffineTransform.identity
    var relatedStart:Double         = 0.0
    var relatedDuration:Double      = 1.0
    
    convenience init(value:CGAffineTransform, relatedStart:Double, relatedDuration:Double) {
        self.init()
        self.value = value
        self.relatedStart = relatedStart
        self.relatedDuration = relatedDuration
    }
    
    convenience init(item:PGTransformValue.Item, relatedStart:Double, relatedDuration:Double) {
        self.init()
        self.value = item.value
        self.relatedStart = relatedStart
        self.relatedDuration = relatedDuration
    }
}

extension PGTransformValue {
    public enum Item {
        case x(CGFloat)
        case y(CGFloat)
        case move(CGFloat, CGFloat)
        case rateX(CGFloat)
        case rateY(CGFloat)
        case rateMove(CGFloat, CGFloat)
        case zero
    }
}

extension PGTransformValue.Item {
    public var value:CGAffineTransform {
        switch self {
        case .x(let x):               return CGAffineTransform.init(translationX: x, y: 0)
        case .y(let y):               return CGAffineTransform.init(translationX: 0, y: y)
        case .move(let x, let y):     return CGAffineTransform.init(translationX: x, y: y)
        case .rateX(let x):           return CGAffineTransform.init(translationX: PGTransformValue.Item.width(x), y: 0)
        case .rateY(let y):           return CGAffineTransform.init(translationX: 0, y: PGTransformValue.Item.height(y))
        case .rateMove(let x, let y): return CGAffineTransform.init(translationX: PGTransformValue.Item.width(x), y: PGTransformValue.Item.height(y))
        case .zero:                   return CGAffineTransform.identity
        }
    }
    
    public static func width(_ multiplier:CGFloat = 1.0) -> CGFloat  { return UIScreen.main.bounds.width  * multiplier }
    public static func height(_ multiplier:CGFloat = 1.0) -> CGFloat { return UIScreen.main.bounds.height * multiplier }
}

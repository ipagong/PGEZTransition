//
//  PGTransformAlpha.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 13..
//  Copyright © 2018년 iPagong. All rights reserved.
//

import Foundation

@objc
open class PGTransformAlpha : NSObject {
    var value:CGFloat               = 1.0
    var relatedStart:Double         = 0.0
    var relatedDuration:Double      = 1.0
    
    public convenience init(value:CGFloat, relatedStart:Double, relatedDuration:Double) {
        self.init()
        self.value = value
        self.relatedStart = relatedStart
        self.relatedDuration = relatedDuration
    }
}

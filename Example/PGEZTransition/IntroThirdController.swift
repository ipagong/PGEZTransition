//
//  IntroThirdController.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 12..
//  Copyright © 2018년 iPagong. All rights reserved.
//

import UIKit
import PGEZTransition

class IntroThirdController: UIViewController {
    
    @IBOutlet weak var transformView: PGTransformView!
    
    @IBOutlet weak var titleTop: PGTransformLabel!
    @IBOutlet weak var title1: PGTransformLabel!
    @IBOutlet weak var title2: PGTransformLabel!
    
    @IBOutlet weak var image1: PGTransformImageView!
    @IBOutlet weak var image2: PGTransformImageView!
    @IBOutlet weak var image3: PGTransformImageView!
    @IBOutlet weak var image4: PGTransformImageView!
    
    @IBOutlet weak var menuView: PGTransformView!
    
    @IBOutlet weak var jumpButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitionSetup()
    }
}

extension IntroThirdController {
    
    func transitionSetup() {
        transformView
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 1.0)
        
        //메인 캐릭터 이미지
        image1
            .setStartTransform(.rateX(0.8), start: 0.0, duration: 1.0)
            .setStartAlpha(1.0, start: 0.0, duration: 1.0)
        
        //좌우 바닥 이펙트 이미지
        image2
            .setStartTransform(.rateX(0.3), start: 0.5, duration: 0.7)
            .setStartAlpha(0.0, start: 0.6, duration: 1.0)
        
        //좌측 동그라미 이미지
        image3
            .setStartTransform(.rateX(0.3), start: 0.5, duration: 1.0)
            .setStartAlpha(0.0, start: 0.8, duration: 1.0)
        
        //주변 반짝반짝 이미지
        image4
            .setStartTransform(.rateX(0.4), start: 0.5, duration: 1.0)
            .setStartAlpha(0.0, start: 0.7, duration: 1.0)
        
        title1
            .setStartTransform(.rateX(0.2), start: 0.3, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.zero, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
        title2
            .setStartTransform(.rateX(0.3), start: 0.3, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.zero, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
        titleTop
            .setStartTransform(.zero, start: 0.0, duration: 1.0)
            .setStartAlpha(1.0, start: 0.0, duration: 1.0)
        
        menuView
            .setStartAlpha(1.0, start: 1.0, duration: 0.0)
            .setEndAlpha(1.0, start: 1.0, duration: 0.0)
        
    }
}


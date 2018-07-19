//
//  IntroFirstController.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 12..
//  Copyright © 2018년 iPagong. All rights reserved.
//

import UIKit
import PGEZTransition

class IntroFirstController: UIViewController {
    
    @IBOutlet weak var transformView: PGTransformView!
    
    @IBOutlet weak var title1: PGTransformLabel!
    @IBOutlet weak var title2: PGTransformLabel!
    
    @IBOutlet weak var image1: PGTransformImageView!
    @IBOutlet weak var image2: PGTransformImageView!
    @IBOutlet weak var image3: PGTransformImageView!
    @IBOutlet weak var image4: PGTransformImageView!
    
    @IBOutlet weak var menuView: PGTransformView!
    
    @IBOutlet weak var jumpButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var transition:PGTransformTransition!
    
    private lazy var nextVc:IntroSecondController = {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroSecondController") as! IntroSecondController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitionSetup()
    }
    
    @IBAction func onNext(_ sender: Any) {
        self.transition.presentTransformViewController()
    }
}

extension IntroFirstController {
    
    func transitionSetup() {
     
        self.transition = PGTransformTransition.init(target: self, presenting: self.nextVc)
        
        transformView
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 1.0)
        
        //라이언 이미지
        image1
            .setStartTransform(.rateX(1.0), start: 0.0, duration: 1.0)
            .setStartAlpha(1.0, start: 0.0, duration: 1.0)
            .setEndTransform(.rateX(-1.0), start: 0.0, duration: 1.0)
            .setEndAlpha(1.0, start: 0.0, duration: 1.0)
        
        //코인 이미지
        image2
            .setStartTransform(.rateX(0.3), start: 0.0, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.rateX(-0.3), start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
        //반짝/리듬 이미지
        image3
            .setStartTransform(.rateX(1.3), start: 0.1, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.rateX(-1.3), start: 0.1, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 1.0)
        
        //오예 이미지
        image4
            .setStartTransform(.rateX(0.3), start: 0.0, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.rateX(-0.3), start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
        title1
            .setStartTransform(.rateX(0.3), start: 0.0, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.zero, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
        title2
            .setStartTransform(.rateX(0.5), start: 0.0, duration: 1.0)
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndTransform(.zero, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
        menuView
            .setStartAlpha(1.0, start: 1.0, duration: 0.0)
            .setEndAlpha(1.0, start: 1.0, duration: 0.0)
    }
}

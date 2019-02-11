//
//  IntroSecondController.swift
//  iPagong
//
//  Created by ipagong on 2018. 7. 12..
//  Copyright © 2018년 iPagong. All rights reserved.
//

import UIKit
import PGEZTransition

class IntroSecondController: UIViewController {
    
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
    
    private var transition:PGTransformPushTransition!
    
    private lazy var nextVc:IntroThirdController = {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroThirdController") as! IntroThirdController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transitionSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    } 
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onNext(_ sender: Any) {
        self.transition.showTransformViewController()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension IntroSecondController {
    
    func transitionSetup() {
        
        self.transition = PGTransformPushTransition.init(target: self, showing: self.nextVc)
        
        transformView
            .setStartAlpha(0.0, start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 1.0)
        
        //무지 가운데 이미지
        image1
            .setStartTransform(.rateX(1.1), start: 0.0, duration: 1.0)
            .setStartAlpha(1.0, start: 0.0, duration: 1.0)
            .setEndTransform(.rateX(-0.5), start: 0.0, duration: 0.8)
            .setEndAlpha(1.0, start: 0.0, duration: 1.0)
        
        //제이쥐 네오 튜브 좌우 이미지
        image2
            .setStartTransform(.rateX(0.8), start: 0.15, duration: 1.0)
            .setStartAlpha(0.0, start: 0.2, duration: 0.6)
            .setEndTransform(.rateX(-0.7), start: 0.0, duration: 0.7)
            .setEndAlpha(0.0, start: 0.2, duration: 0.6)
        
        //우측 프로도 피치 이미지
        image3
            .setStartTransform(.rateX(0.9), start: 0.0, duration: 1.0)
            .setStartAlpha(1.0, start: 0.0, duration: 1.0)
            .setEndTransform(.rateX(-1.0), start: 0.0, duration: 0.8)
            .setEndAlpha(0.0, start: 0.2, duration: 0.8)
        
        //주변 둠칙둠칙 이미지
        image4
            .setStartTransform(.rateX(0.3), start: 0.0, duration: 1.0)
            .setStartAlpha(0.0, start: 0.7, duration: 1.0)
            .setEndTransform(.rateX(-0.3), start: 0.0, duration: 1.0)
            .setEndAlpha(0.0, start: 0.0, duration: 0.3)
        
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
            .setStartTransform(.y(15), start: 0.3, duration: 0.4)
            .setStartAlpha(0.0, start: 0.2, duration: 0.4)
            .setEndTransform(.zero, start: 0.0, duration: 1.0)
            .setEndAlpha(1.0, start: 0.0, duration: 1.0)
        
        menuView
            .setStartAlpha(1.0, start: 1.0, duration: 0.0)
            .setEndAlpha(1.0, start: 1.0, duration: 0.0)
    }
}

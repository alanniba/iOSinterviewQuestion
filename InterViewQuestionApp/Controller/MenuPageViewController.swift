//
//  MenuPageViewController.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/20.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import UIKit
import Lottie
class MenuPageViewController: UIViewController {
    @IBOutlet private var animationView: LOTAnimationView!
    
    @IBOutlet weak var testBut: UIButton!
    @IBOutlet weak var prepareBut: UIButton!
    @IBOutlet weak var reviewBut: UIButton!
    @IBOutlet weak var downloadsBut: UIButton!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var categoryStackViewCenterConstrain: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
        startAnimation()
        layoutBut()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        animationView.play()
    }
    
    //MARK:- setup functions
    fileprivate func setUpNavigationBar(){
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func startAnimation(){
        animationView.setAnimation(named: "interviewQeustionPageAnimation")
    }
    
    //MARK:- actions from xib
    @IBAction func toPreparePageAction(_ sender: Any) {
        let preparePageVC = PreparePageViewController()
        navigationController?.pushViewController(preparePageVC, animated: true)
    }
    
    @IBAction func toTestPageAction(_ sender: Any) {
        let testPageVC = TestViewController()
        navigationController?.pushViewController(testPageVC, animated: true)
    }
    @IBAction func toReviewPageAction(_ sender: Any) {
    }
    @IBAction func handleiOSCategory(_ sender: Any) {
        self.animationView.play()
        self.animatButs()
    }
    @IBAction func toDownloadPageAction(_ sender: Any) {
        let downloadVC = DownloadsViewController()
        navigationController?.pushViewController(downloadVC, animated: true)
    }
    
    var testButCenterXConstrain : NSLayoutConstraint!
//    var prepareButCenterXConstrain : NSLayoutConstraint!
//    var reviewButCenterXConstrain : NSLayoutConstraint!
    var centerXForBut: NSLayoutConstraint!
    fileprivate func layoutBut(){
        
        testBut.translatesAutoresizingMaskIntoConstraints = false
        testButCenterXConstrain = testBut.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 600)
        testButCenterXConstrain.isActive = true
        centerXForBut = testBut.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        testBut.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true

        
        prepareBut.translatesAutoresizingMaskIntoConstraints = false
        prepareBut.topAnchor.constraint(equalTo: testBut.bottomAnchor, constant: 24).isActive = true

        
        reviewBut.translatesAutoresizingMaskIntoConstraints = false
        reviewBut.topAnchor.constraint(equalTo: prepareBut.bottomAnchor, constant: 24).isActive = true
        
        downloadsBut.translatesAutoresizingMaskIntoConstraints = false
        downloadsBut.topAnchor.constraint(equalTo: reviewBut.bottomAnchor, constant: 24).isActive = true

    }
    fileprivate func animatButs(){
        testButCenterXConstrain.isActive = false
        centerXForBut.isActive = true
        categoryStackViewCenterConstrain.constant = -800
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded()
        })
        
    }

}

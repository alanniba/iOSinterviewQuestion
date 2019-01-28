//
//  TestViewController.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/25.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    //MARK:- varibles
    var seconds = 0
    var timer = Timer()
    var timerIsOn = false
    //MARK:- ib outlets
    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var recordIndecator: UIView!
    @IBOutlet weak var answerBut: UIButton!


    //MARK:- ib actions
    @IBAction func handleStart(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    @objc private func processTimer(){
        seconds = seconds + 1
        recordTime.text = "\(seconds)"
        if seconds % 4 == 0{
            UIView.animate(withDuration: 0.5) {
            }
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: {
                self.recordIndecator.alpha = 0
            }) { (_) in
                self.recordIndecator.alpha = 1

            }
        }
        
    }
    

}

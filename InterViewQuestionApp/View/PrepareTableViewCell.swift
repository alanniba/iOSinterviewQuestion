//
//  PrepareTableViewCell.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/20.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import UIKit

class PrepareTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var importanceMark: UIImageView!
    @IBOutlet weak var flagMark: UIImageView!
    @IBOutlet weak var tooeasyMark: UIImageView!
    @IBOutlet weak var level: UIImageView!
    var question : Question!{
        didSet{
            title.text = question.title ?? ""
            setImage(levelInt: question.level ?? 1)
            setMarks(int: question.isMarkImpartant ?? 0, imageView: importanceMark)
            setMarks(int: question.isMarkeasyForget ?? 0, imageView: flagMark)
            setMarks(int: question.isMarkTooEasy ?? 0, imageView: tooeasyMark)
        }
    }

    //MARK:- helper function
    fileprivate func setImage(levelInt : Int){
        switch  levelInt {
        case 1:
            level.image = #imageLiteral(resourceName: "Group 4")
        case 2:
            level.image = #imageLiteral(resourceName: "Group 5")
        case 3:
            level.image = #imageLiteral(resourceName: "Group 6")
        default:
            level.image = #imageLiteral(resourceName: "Group 7")

        }
    }
    
    fileprivate func setMarks(int : Int , imageView : UIImageView){
        if int == 0{
            imageView.alpha = 0.5
        } else {
            imageView.alpha = 1
        }
    }
}

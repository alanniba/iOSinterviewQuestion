//
//  Question.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/20.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import Foundation
struct Question {
    var title: String?
    var level: Int?
    var isMarkImpartant : Int?
    var isMarkeasyForget : Int?
    var isMarkTooEasy : Int?
    var keyPoint: Array<Any>?
    var correctAnswer : String?
    var myAnswer: String?
    var cardID : String?
    
    init(dictionary: [String: Any]) {
        self.title = dictionary["title"]as? String ?? ""
        self.level = dictionary["diffeculty"] as? Int ?? 0
        self.isMarkImpartant = dictionary["importantFlag"] as? Int ?? 0
        self.isMarkTooEasy = dictionary["tooEasyFlag"] as? Int ?? 0
        self.isMarkeasyForget = dictionary["easyForgetFlag"] as? Int ?? 0
        self.keyPoint = dictionary["keyPoints"] as? Array ?? []
        self.correctAnswer = dictionary["correctAnswer"] as? String ?? ""
        self.myAnswer = dictionary["userAnswer"] as? String ?? ""
        self.cardID = dictionary["cardID"] as? String ?? ""
    }
}

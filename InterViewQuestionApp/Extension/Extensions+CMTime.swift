//
//  Extensions+CMTime.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/22.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import AVKit

extension CMTime{
    
    func toDisplayString() -> String{
        if CMTimeGetSeconds(self).isNaN{
            return "--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d",minutes,seconds)
        return timeFormatString
    }
}

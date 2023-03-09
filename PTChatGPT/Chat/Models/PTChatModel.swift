//
//  PTChatModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTChatModel: PTBaseModel {
    ///0:type,1voice
    var questionType:Int = 0
    var question:String = ""
    var questionVoiceURL:String = ""
    var questionDate:String = ""
    ///0:text,1image
    var answerType:Int = 0
    var answer:String = ""
    var answerDate:String = ""
    var answerImageURL:String = ""
}

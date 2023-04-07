//
//  PTCostMainModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 7/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTCostMainModel: PTBaseModel {
    ///0是默认文字内容1是图片
    var historyType:Int = 0
    ///消费时间
    var costDate:String = ""
    ///问题
    var question:String = ""
    ///答案
    var answer:String = ""
    ///图片URL
    var imageURL:[PTImageGenerationData] = [PTImageGenerationData]()
    ///图片大小
    var imageSize:String = ""
    ///消耗情况
    var tokenUsage:PTReceiveChatUsage = PTReceiveChatUsage()
    ///模型名字
    var modelName:String = ""
}

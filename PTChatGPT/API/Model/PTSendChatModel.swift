//
//  PTSendChatModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

enum PTSendRole:String {
    case user = "user"
    case system = "system"
    case assistant = "assistant"
}

class PTSendChatMessageModel: PTBaseModel {
    var role:String = PTSendRole.user.rawValue
    var content:String = ""
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class PTSendChatModel: PTBaseModel {
    ///GPT3.5之后的消息模型
    var messages: [PTSendChatMessageModel]!
    ///模型
    var model: String = OpenAIModelType.chat(.chatgpt).modelName
    ///用户标识
    var user: String = UUID().uuidString
    ///AI智障程度
    var temperature: Double = 1
    //MARK: 靠,下面的太多了,很少用到,直接引用接口文档https://platform.openai.com/docs/api-reference/chat/create
    var top_p: Double = 1
    var n: Int = 1
    var stream:Bool = false
    var stop: [String]? = nil
    var max_tokens: Int = 0
    var presence_penalty: Double = 0
    var frequency_penalty: Double = 0
    var logit_bias: [Int: Double]? = nil
}

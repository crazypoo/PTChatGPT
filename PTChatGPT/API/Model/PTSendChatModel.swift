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
    var messages: [PTSendChatMessageModel]!
    var model: String = OpenAIModelType.chat(.chatgpt).modelName
    var user: String = UUID().uuidString
    var temperature: Double = 1
    var top_p: Double = 1
    var n: Int = 1
    var stream:Bool = false
    var stop: [String]? = nil
    var max_tokens: Int = 0
    var presence_penalty: Double = 0
    var frequency_penalty: Double = 0
    var logit_bias: [Int: Double]? = nil
}

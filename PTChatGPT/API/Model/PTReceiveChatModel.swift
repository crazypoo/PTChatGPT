//
//  PTReceiveChatModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTReceiveChatUsage :PTBaseModel {
    var total_tokens: Int = 0
    var completion_tokens: Int = 0
    var prompt_tokens: Int = 0

}

class PTReceiveChatMessage :PTBaseModel {
    var content: String = ""
    var role: String = ""
}

class PTReceiveChatChoices :PTBaseModel {
    var index: Int = 0
    var message: PTReceiveChatMessage?
    var finish_reason: String = ""
}

class PTReceiveChatModel :PTChatGPTBaseModel {
    var id: String = ""
    var object: String = ""
    var created: Int = 0
    var usage: PTReceiveChatUsage?
    var choices: [PTReceiveChatChoices]?
}

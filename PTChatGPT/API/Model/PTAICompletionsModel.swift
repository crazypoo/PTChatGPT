//
//  PTAICompletionsModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTAICompletionsChoices :PTBaseModel {
    var index: Int = 0
    var finish_reason: String = ""
    var logprobs: String = ""
    var text: String = ""
}

class PTAICompletionsUsage :PTBaseModel {
    var total_tokens: Int = 0
    var completion_tokens: Int = 0
    var prompt_tokens: Int = 0
}

class PTAICompletionsModel :PTChatGPTBaseModel {
    var id: String = ""
    var object: String = ""
    var created: Int = 0
    var model: String = ""
    var choices: [PTAICompletionsChoices]?
    var usage: PTAICompletionsUsage?
}

//
//  PTAIEditsModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTAIEditsUsage :PTBaseModel {
    var total_tokens: Int = 0
    var completion_tokens: Int = 0
    var prompt_tokens: Int = 0
}

class PTAIEditsChoices :PTBaseModel {
    var index: Int = 0
    var text: String = ""
}

class PTAIEditsModel :PTBaseModel {
    var object: String = ""
    var created: Int = 0
    var usage: PTAIEditsUsage?
    var choices: [PTAIEditsChoices]?
}

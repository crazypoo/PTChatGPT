//
//  PTAIEditsModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTAIEditsChoices :PTBaseModel {
    var index: Int = 0
    var text: String = ""
}

class PTAIEditsModel :PTChatGPTBaseModel {
    var object: String = ""
    var created: Int = 0
    var usage: PTReceiveChatUsage?
    var choices: [PTAIEditsChoices]?
}

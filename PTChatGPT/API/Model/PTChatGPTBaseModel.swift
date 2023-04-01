//
//  PTChatGPTBaseModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 2/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTChatGPTBaseModel: PTBaseModel {
    var error:PTChatGPTErrorModel?
}

class PTChatGPTErrorModel:PTBaseModel {
    var code : String = ""
    var type : String = ""
    var message : String = ""
    var param : String = ""
}

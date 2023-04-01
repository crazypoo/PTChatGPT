//
//  PTImageGeneration.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTImageGenerationData :PTBaseModel {
    var url: String = ""
}

class PTImageGeneration :PTBaseModel {
    var created: Int = 0
    var data: [PTImageGenerationData]?
}

//
//  PTSampleModels.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 28/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTSampleMainModels:PTBaseModel {
    var segmentName:String = ""
    var persion:[PTSampleModels] = [PTSampleModels]()
}

class PTSampleModels: PTBaseModel {
    var keyName:String = ""
    var systemContent:String = ""
    var who:String = "@anonymous"
    var imported:Bool = false
}

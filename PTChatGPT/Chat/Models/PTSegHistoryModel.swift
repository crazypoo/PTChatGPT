//
//  PTSegHistoryModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 19/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTSegHistoryModel: PTBaseModel {
    var keyName:String = ""
    var systemContent:String = ""
    var historyModel:[PTChatModel] = [PTChatModel]()
}

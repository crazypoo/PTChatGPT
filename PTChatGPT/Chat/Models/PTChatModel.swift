//
//  PTChatModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTChatModel: PTBaseModel {
    ///Type: 0文字,1聲音,2圖片
    var messageType:Int = 0
    ///信息是否發送成功
    var messageSendSuccess:Bool = true
    ///消息內容
    var messageText:String = ""
    ///消息媒體內容URL
    var messageMediaURL:String = ""
    ///消息日期
    var messageDateString :String = ""
    ///消息發送人
    var outgoing:Bool = true
    
    var correctionText:String = ""
    
    var localFileName:String = ""
    
    var editMainName:String = ""
    var editMaskName:String = ""
}

class PTFavouriteModel:PTBaseModel {
    var chats:[PTChatModel] = [PTChatModel]()
    var chatContent:String = ""
}

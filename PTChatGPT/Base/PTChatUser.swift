//
//  PTChatUser.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import Foundation
import MessageKit

struct PTChatUser: SenderType,Equatable {
    var senderId:String
    var displayName: String
}

//
//  PTChatData.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import MessageKit
import PooTools

final internal class PTChatData
{
    static let share = PTChatData()
    
    private init() {
        
    }
        
    let user = PTChatUser(senderId: "000000", displayName: PTLanguage.share.text(forKey: "chat_User"))
    let bot = PTChatUser(senderId: "000001", displayName: "ZolaAi")
    
    func getAvatarFor(sender:SenderType) -> Avatar
    {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").first
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        switch sender.senderId {
        case "000000":
            return Avatar(image: #imageLiteral(resourceName: "DemoImage"), initials: initials)
        default:
            return Avatar(image: #imageLiteral(resourceName: "ChatGPT"), initials: initials)
        }
    }
}

//
//  PTAppConfig.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

///用戶的BubbleColor key
let uUserBubbleColor = "uUserBubbleColor"
///機器人的BubbleColor key
let uBotBubbleColor = "uBotBubbleColor"
///歷史記錄 key
let uChatHistory = "ChatHistory"
///保存記錄 key
let uSaveChat = "uSaveChat"

let kSeparator = "[,]"

extension UIColor
{
    static let botBubbleColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    static let userBubbleColor = UIColor.systemBlue
    /// 字體顏色
    private(set) static var gobalTextColor = PTDrakModeOption.colorLightDark(lightColor: .black, darkColor: UIColor.white)
    private(set) static var gobalBackgroundColor = PTDrakModeOption.colorLightDark(lightColor: .white, darkColor: UIColor.black)
}

class PTAppConfig {
    static let share = PTAppConfig()
    
    var userBubbleColor:UIColor = UserDefaults.standard.value(forKey: uUserBubbleColor) == nil ? .userBubbleColor : UIColor(hexString: UserDefaults.standard.value(forKey: uUserBubbleColor) as! String)!
    var botBubbleColor:UIColor = UserDefaults.standard.value(forKey: uBotBubbleColor) == nil ? .botBubbleColor : UIColor(hexString: UserDefaults.standard.value(forKey: uBotBubbleColor) as! String)!
    
    func getSaveChatData() -> [PTChatModel]
    {
        var saveChatModel = [PTChatModel]()
        if let userHistoryModelString :String = UserDefaults.standard.value(forKey: uSaveChat) as? String
        {
            if !userHistoryModelString.stringIsEmpty()
            {
                let userModelsStringArr = userHistoryModelString.components(separatedBy: kSeparator)
                userModelsStringArr.enumerated().forEach { index,value in
                    let models = PTChatModel.deserialize(from: value)
                    saveChatModel.append(models!)
                }
            }
        }
        return saveChatModel
    }
}

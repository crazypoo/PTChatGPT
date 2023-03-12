//
//  PTAppConfig.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import BRPickerView
import SwifterSwift

///用戶的BubbleColor key
let uUserBubbleColor = "uUserBubbleColor"
///機器人的BubbleColor key
let uBotBubbleColor = "uBotBubbleColor"
///用戶的TextColor key
let uUserTextColor = "uUserTextColor"
///機器人的TextColor key
let uBotTextColor = "uBotTextColor"
///歷史記錄 key
let uChatHistory = "ChatHistory"
///保存記錄 key
let uSaveChat = "uSaveChat"
///保存的機器人類型
let uAiModelType = "uAiModelType"
///保存的機器人智障程度
let uAiSmart = "uAiSmart"
///保存的用戶的頭像
let uUserIcon = "uUserIcon"
///保存的AI畫圖大小
let uAiDrawSize = "uAiDrawSize"
let uTokenKey = "UserToken"
let uLanguageKey = "UserLanguage"
///语音的波纹颜色key
let uWaveColor = "uWaveColor"

let kSeparator = "[,]"

let getApiUrl = "https://platform.openai.com/account/api-keys"
let myGithubUrl = "https://github.com/crazypoo"
let projectGithubUrl = "https://github.com/crazypoo/PTChatGPT"

let AppDisclaimer = PTLanguage.share.text(forKey: "disclaimer_App_Info")
let ExternalLinksDisclaimer = PTLanguage.share.text(forKey: "disclaimer_External_info")

extension UIColor
{
    static let botBubbleColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    static let userBubbleColor = UIColor.systemBlue
    
    static let userTextColor = UIColor.darkText
    static let botTextColor = UIColor.darkText
    /// 字體顏色
    private(set) static var gobalTextColor = PTDrakModeOption.colorLightDark(lightColor: .black, darkColor: UIColor.white)
    private(set) static var gobalBackgroundColor = PTDrakModeOption.colorLightDark(lightColor: .white, darkColor: UIColor.black)
    
    private(set) static var gobalScrollerBackgroundColor = PTDrakModeOption.colorLightDark(lightColor: PTAppBaseConfig.share.viewControllerBaseBackgroundColor, darkColor: UIColor.black)
    
    private(set) static var gobalCellBackgroundColor = PTDrakModeOption.colorLightDark(lightColor: .white, darkColor: .Black25PercentColor)
}

extension CGSize {
    static func from(archivedData data: Data) throws -> CGSize {
        var sizeObj = CGSize.zero
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        if let size = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? NSValue
        {
            sizeObj =  size.cgSizeValue
        }
        unarchiver.finishDecoding()
        return sizeObj
    }
}

class PTAppConfig {
    static let share = PTAppConfig()
    
    var userIcon:Data = UserDefaults.standard.value(forKey: uUserIcon) == nil ? UIImage(named: "DemoImage")!.pngData()! : (UserDefaults.standard.value(forKey: uUserIcon) as! Data)
    {
        didSet{
            UserDefaults.standard.set(self.userIcon,forKey: uUserIcon)
        }
    }

    var userBubbleColor:UIColor = UserDefaults.standard.value(forKey: uUserBubbleColor) == nil ? .userBubbleColor : UIColor(hexString: UserDefaults.standard.value(forKey: uUserBubbleColor) as! String)!
    {
        didSet{
            UserDefaults.standard.set(self.userBubbleColor.hexString(),forKey: uUserBubbleColor)
        }
    }
    var botBubbleColor:UIColor = UserDefaults.standard.value(forKey: uBotBubbleColor) == nil ? .botBubbleColor : UIColor(hexString: UserDefaults.standard.value(forKey: uBotBubbleColor) as! String)!
    {
        didSet{
            UserDefaults.standard.set(self.botBubbleColor.hexString(),forKey: uBotBubbleColor)
        }
    }
    
    var userTextColor:UIColor = UserDefaults.standard.value(forKey: uUserTextColor) == nil ? .userTextColor : UIColor(hexString: UserDefaults.standard.value(forKey: uUserTextColor) as! String)!
    {
        didSet{
            UserDefaults.standard.set(self.userTextColor.hexString(),forKey: uUserTextColor)
        }
    }
    var botTextColor:UIColor = UserDefaults.standard.value(forKey: uBotTextColor) == nil ? .botTextColor : UIColor(hexString: UserDefaults.standard.value(forKey: uBotTextColor) as! String)!
    {
        didSet{
            UserDefaults.standard.set(self.botTextColor.hexString(),forKey: uBotTextColor)
        }
    }
    var waveColor:UIColor = UserDefaults.standard.value(forKey: uWaveColor) == nil ? .red : UIColor(hexString: UserDefaults.standard.value(forKey: uWaveColor) as! String)!
    {
        didSet{
            UserDefaults.standard.set(self.botTextColor.hexString(),forKey: uWaveColor)
        }
    }


    var aiModelType:String = UserDefaults.standard.value(forKey: uAiModelType) == nil ? "text-davinci-003" : UserDefaults.standard.value(forKey: uAiModelType) as! String
    {
        didSet{
            UserDefaults.standard.set(self.aiModelType,forKey: uAiModelType)
        }
    }
    var apiToken:String = UserDefaults.standard.value(forKey: uTokenKey) == nil ? "" : UserDefaults.standard.value(forKey: uTokenKey) as! String
    {
        didSet{
            UserDefaults.standard.set(self.apiToken,forKey: uTokenKey)
        }
    }
    var aiSmart:Double = UserDefaults.standard.value(forKey: uAiSmart) == nil ? 0.2 : UserDefaults.standard.value(forKey: uAiSmart) as! Double
    {
        didSet{
            UserDefaults.standard.set(self.aiSmart,forKey: uAiSmart)
        }
    }
    var aiDrawSize:CGSize = UserDefaults.standard.value(forKey: uAiDrawSize) == nil ? CGSize(width: 1024, height: 1024) : (try? CGSize.from(archivedData: UserDefaults.standard.value(forKey: uAiDrawSize) as! Data))!
    {
        didSet
        {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: self.aiDrawSize, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: uAiDrawSize)
        }
    }
        
    var language:String = UserDefaults.standard.value(forKey: uLanguageKey) == nil ? OSSVoiceEnum.ChineseSimplified.rawValue : UserDefaults.standard.value(forKey: uLanguageKey) as! String
    {
        didSet
        {
            UserDefaults.standard.set(self.language, forKey: uLanguageKey)
        }
    }

    lazy var languagePickerData:[String] = {
        var data = [String]()
        OSSVoiceEnum.allCases.enumerated().forEach { index,value in
            data.append(value.rawValue)
        }
        return data
    }()
    
    func getAIMpdelType(typeString:String) -> OpenAIModelType
    {
        if typeString == "text-davinci-003"
        {
            return OpenAIModelType.gpt3(.davinci)
        }
        else if typeString == "text-curie-001"
        {
            return OpenAIModelType.gpt3(.curie)
        }
        else if typeString == "text-babbage-001"
        {
            return OpenAIModelType.gpt3(.babbage)
        }
        else if typeString == "text-ada-001"
        {
            return OpenAIModelType.gpt3(.ada)
        }
        else if typeString == "code-davinci-002"
        {
            return OpenAIModelType.codex(.davinci)
        }
        else if typeString == "code-cushman-001"
        {
            return OpenAIModelType.codex(.cushman)
        }
        else if typeString == "text-davinci-edit-001"
        {
            return OpenAIModelType.feature(.davinci)
        }
        else if typeString == "gpt-3.5-turbo"
        {
            return OpenAIModelType.chat(.chatgpt)
        }
        else if typeString == "gpt-3.5-turbo-0301"
        {
            return OpenAIModelType.chat(.chatgpt0301)
        }
        else
        {
            return OpenAIModelType.gpt3(.davinci)
        }
    }
    
    func getAiModelPickerDate(currentAi:String,handle:@escaping (_ pickerArr:[BRResultModel],_ currentAiIndex:[NSNumber])->Void)
    {
        var modelArr = [BRResultModel]()
        
        let gptMainModel = BRResultModel()
        gptMainModel.parentKey = "-1"
        gptMainModel.parentValue = ""
        gptMainModel.key = "GPT"
        gptMainModel.value = "GPT"
        modelArr.append(gptMainModel)
        
        let gptDavinciModel = BRResultModel()
        gptDavinciModel.parentKey = "GPT"
        gptDavinciModel.parentValue = OpenAIModelType.gpt3(.davinci).modelName
        gptDavinciModel.key = "1"
        gptDavinciModel.value = OpenAIModelType.gpt3(.davinci).modelName
        modelArr.append(gptDavinciModel)
        
        let gptCurieModel = BRResultModel()
        gptCurieModel.parentKey = "GPT"
        gptCurieModel.parentValue = OpenAIModelType.gpt3(.curie).modelName
        gptCurieModel.key = "2"
        gptCurieModel.value = OpenAIModelType.gpt3(.curie).modelName
        modelArr.append(gptCurieModel)

        let gptBabbageModel = BRResultModel()
        gptBabbageModel.parentKey = "GPT"
        gptBabbageModel.parentValue = OpenAIModelType.gpt3(.babbage).modelName
        gptBabbageModel.key = "3"
        gptBabbageModel.value = OpenAIModelType.gpt3(.babbage).modelName
        modelArr.append(gptBabbageModel)

        let gptAdaModel = BRResultModel()
        gptAdaModel.parentKey = "GPT"
        gptAdaModel.parentValue = OpenAIModelType.gpt3(.ada).modelName
        gptAdaModel.key = "4"
        gptAdaModel.value = OpenAIModelType.gpt3(.ada).modelName
        modelArr.append(gptAdaModel)

        let codexMainModel = BRResultModel()
        codexMainModel.parentKey = "-1"
        codexMainModel.parentValue = ""
        codexMainModel.key = "CODEX"
        codexMainModel.value = "CODEX"
        modelArr.append(codexMainModel)

        let codexDavinciModel = BRResultModel()
        codexDavinciModel.parentKey = "CODEX"
        codexDavinciModel.parentValue = OpenAIModelType.codex(.davinci).modelName
        codexDavinciModel.key = "1"
        codexDavinciModel.value = OpenAIModelType.codex(.davinci).modelName
        modelArr.append(codexDavinciModel)

        let codexCushmanModel = BRResultModel()
        codexCushmanModel.parentKey = "CODEX"
        codexCushmanModel.parentValue = OpenAIModelType.codex(.cushman).modelName
        codexCushmanModel.key = "2"
        codexCushmanModel.value = OpenAIModelType.codex(.cushman).modelName
        modelArr.append(codexCushmanModel)

        let featureMainModel = BRResultModel()
        featureMainModel.parentKey = "-1"
        featureMainModel.parentValue = ""
        featureMainModel.key = "FEATURE"
        featureMainModel.value = "FEATURE"
        modelArr.append(featureMainModel)

        let featureDavinciModel = BRResultModel()
        featureDavinciModel.parentKey = "FEATURE"
        featureDavinciModel.parentValue = OpenAIModelType.feature(.davinci).modelName
        featureDavinciModel.key = "3"
        featureDavinciModel.value = OpenAIModelType.feature(.davinci).modelName
        modelArr.append(featureDavinciModel)
        
        let gptXMainModel = BRResultModel()
        gptXMainModel.parentKey = "-1"
        gptXMainModel.parentValue = ""
        gptXMainModel.key = "GPTX"
        gptXMainModel.value = "GPTX"
        modelArr.append(gptXMainModel)

        let gptThreePointFiveModel = BRResultModel()
        gptThreePointFiveModel.parentKey = "GPTX"
        gptThreePointFiveModel.parentValue = OpenAIModelType.chat(.chatgpt).modelName
        gptThreePointFiveModel.key = "1"
        gptThreePointFiveModel.value = OpenAIModelType.chat(.chatgpt).modelName
        modelArr.append(gptThreePointFiveModel)

        let gptThreePointFive0301Model = BRResultModel()
        gptThreePointFive0301Model.parentKey = "GPTX"
        gptThreePointFive0301Model.parentValue = OpenAIModelType.chat(.chatgpt0301).modelName
        gptThreePointFive0301Model.key = "2"
        gptThreePointFive0301Model.value = OpenAIModelType.chat(.chatgpt0301).modelName
        modelArr.append(gptThreePointFive0301Model)

        var indexPath = [NSNumber]()
        if currentAi == "text-davinci-003"
        {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 0))
        }
        else if currentAi == "text-curie-001"
        {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 1))
        }
        else if currentAi == "text-babbage-001"
        {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 2))
        }
        else if currentAi == "text-ada-001"
        {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 3))
        }
        else if currentAi == "code-davinci-002"
        {
            indexPath.append(NSNumber(value: 1))
            indexPath.append(NSNumber(value: 0))
        }
        else if currentAi == "code-cushman-001"
        {
            indexPath.append(NSNumber(value: 1))
            indexPath.append(NSNumber(value: 1))
        }
        else if currentAi == "text-davinci-edit-001"
        {
            indexPath.append(NSNumber(value: 2))
            indexPath.append(NSNumber(value: 0))
        }
        else if currentAi == "gpt-3.5-turbo"
        {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 0))
        }
        else if currentAi == "gpt-3.5-turbo-0301"
        {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 1))
        }
        else
        {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 0))
        }

        handle(modelArr,indexPath)
    }
    
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
    
    class open func gobal_BRPickerStyle()->BRPickerStyle
    {
        let style = BRPickerStyle()
        style.topCornerRadius = 10
        style.pickerTextFont = .appfont(size: 16)
        style.pickerColor = .gobalBackgroundColor
        style.pickerTextColor = .gobalTextColor
        style.titleBarColor = .gobalBackgroundColor
        style.cancelBtnTitle = PTLanguage.share.text(forKey: "button_Cancel")
        style.cancelTextFont = .appfont(size: 17)
        style.cancelTextColor = .systemBlue
        style.doneBtnTitle = PTLanguage.share.text(forKey: "button_Confirm")
        style.doneTextFont = .appfont(size: 17)
        style.doneTextColor = .systemBlue
        return style
    }

}

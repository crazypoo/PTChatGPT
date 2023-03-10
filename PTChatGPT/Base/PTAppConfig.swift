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

class PTAppConfig {
    static let share = PTAppConfig()
    
    var userBubbleColor:UIColor = UserDefaults.standard.value(forKey: uUserBubbleColor) == nil ? .userBubbleColor : UIColor(hexString: UserDefaults.standard.value(forKey: uUserBubbleColor) as! String)!
    var botBubbleColor:UIColor = UserDefaults.standard.value(forKey: uBotBubbleColor) == nil ? .botBubbleColor : UIColor(hexString: UserDefaults.standard.value(forKey: uBotBubbleColor) as! String)!
    
    var userTextColor:UIColor = UserDefaults.standard.value(forKey: uUserTextColor) == nil ? .userTextColor : UIColor(hexString: UserDefaults.standard.value(forKey: uUserTextColor) as! String)!
    var botTextColor:UIColor = UserDefaults.standard.value(forKey: uBotTextColor) == nil ? .botTextColor : UIColor(hexString: UserDefaults.standard.value(forKey: uBotTextColor) as! String)!

    var aiModelType:String = UserDefaults.standard.value(forKey: uAiModelType) == nil ? "text-davinci-003" : UserDefaults.standard.value(forKey: uAiModelType) as! String
    var apiToken:String = UserDefaults.standard.value(forKey: uTokenKey) == nil ? "" : UserDefaults.standard.value(forKey: uTokenKey) as! String
    
    var language:String = UserDefaults.standard.value(forKey: uLanguageKey) == nil ? OSSVoiceEnum.ChineseSimplified.rawValue : UserDefaults.standard.value(forKey: uLanguageKey) as! String

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
}

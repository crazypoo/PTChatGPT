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
///Seg控制器的历史记录Key
let uSegChatHistory = "uSegChatHistory"
///保存記錄 key
let uSaveChat = "uSaveChat"
///保存的機器人類型
let uAiModelType = "uAiModelType"
///保存的機器人智障程度
let uAiSmart = "uAiSmart"
///保存的用戶的頭像
let uUserIcon = "uUserIcon"
let uUserIconURL = "uUserIconURL"
///保存的AI畫圖大小
let uAiDrawSize = "uAiDrawSize"
///Token key
let uTokenKey = "UserToken"
///Speech key
let uLanguageKey = "UserLanguage"
///语音的波纹颜色key
let uWaveColor = "uWaveColor"
///第一次使用App
let uAppFirstUse = "uAppFirstUse"
///第一次使用iCloud
let uAppFirstiCloud = "uAppFirstiCloud"
///使用iCloud
let uUseiCloud = "uUseiCloud"
///第一次使用App提示
let uFirstCoach = "uFirstCoach"
///图片数量Key
let uGetImageCount = "uGetImageCount"

let uFirstDataChange = "uFirstDataChange"

let kSeparator = "[,]"
let kSeparatorSeg = "[::]"

let kRefreshController = "kRefreshController"
let kRefreshControllerAndLoadNewData = "kRefreshControllerAndLoadNewData"
let kRefreshCurrentTagData = "kRefreshCurrentTagData"

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
    private(set) static var gobalBackgroundColor = PTDrakModeOption.colorLightDark(lightColor: PTAppBaseConfig.share.viewControllerBaseBackgroundColor, darkColor: UIColor.black)
    
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
    
    var firstDataChange:Bool = UserDefaults.standard.value(forKey: uFirstDataChange) == nil ? true : UserDefaults.standard.value(forKey: uFirstDataChange) as! Bool {
        didSet{
            UserDefaults.standard.set(self.firstDataChange,forKey: uFirstDataChange)
        }
    }

    var firstCoach:Bool = UserDefaults.standard.value(forKey: uFirstCoach) == nil ? true : UserDefaults.standard.value(forKey: uFirstCoach) as! Bool {
        didSet{
            UserDefaults.standard.set(self.firstCoach,forKey: uFirstCoach)
        }
    }
    
    var firstUseiCloud:Bool = UserDefaults.standard.value(forKey: uAppFirstiCloud) == nil ? true : UserDefaults.standard.value(forKey: uAppFirstiCloud) as! Bool {
        didSet{
            UserDefaults.standard.set(self.firstUseiCloud,forKey: uAppFirstiCloud)
        }
    }
    
    var firstUseApp:Bool = UserDefaults.standard.value(forKey: uAppFirstUse) == nil ? true : UserDefaults.standard.value(forKey: uAppFirstUse) as! Bool
    {
        didSet{
            UserDefaults.standard.set(self.firstUseApp,forKey: uAppFirstUse)
        }
    }
    
    var cloudSwitch:Bool = UserDefaults.standard.value(forKey: uUseiCloud) == nil ? true : UserDefaults.standard.value(forKey: uUseiCloud) as! Bool
    {
        didSet{
            UserDefaults.standard.set(self.cloudSwitch,forKey: uUseiCloud)
        }
    }
    
    //MARK: 用户头像
    ///用户头像
    var userIconURL:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uUserIconURL) {
                    return value as! String
                } else {
                    return ""
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uUserIconURL) {
                    return value as! String
                } else {
                    return ""
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uUserIconURL)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uUserIconURL)
            }
        }
    }
    var userIcon:Data {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch
            {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let imageURL = icloudURL.appendingPathComponent("userIcon.png")
                    if let imageData = try? Data(contentsOf: imageURL) {
                        return imageData
                    } else {
                        return UIImage(named: "DemoImage")!.pngData()!
                    }
                } else {
                    return UIImage(named: "DemoImage")!.pngData()!
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uUserIcon) {
                    return value as! Data
                } else {
                    return UIImage(named: "DemoImage")!.pngData()!
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let imageURL = icloudURL.appendingPathComponent("userIcon.png")
                    do {
                        try newValue.write(to: imageURL, options: .atomic)
                        self.userIconURL = Date().toString()
                        PTNSLogConsole(">>>>>>>>>>>jobdone")
                    } catch let error {
                        PTNSLogConsole("Failed to write image data to iCloud: \(error.localizedDescription)")
                    }
                }
            } else {
                UserDefaults.standard.set(newValue, forKey: uUserIcon)
            }
        }
    }

    //MARK: 聊天框颜色
    ///用户聊天框颜色
    var userBubbleColor:UIColor {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uUserBubbleColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .userBubbleColor
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uUserBubbleColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .userBubbleColor
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue.hexString(), forKey: uUserBubbleColor)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue.hexString(), forKey: uUserBubbleColor)
            }
        }
    }
    ///机器人聊天框颜色
    var botBubbleColor:UIColor {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uBotBubbleColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .botBubbleColor
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uBotBubbleColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .botBubbleColor
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue.hexString(), forKey: uBotBubbleColor)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue.hexString(), forKey: uBotBubbleColor)
            }
        }
    }
    
    //MARK: 聊天框字体颜色
    ///用户聊天框字体颜色
    var userTextColor:UIColor {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uUserTextColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .userTextColor
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uUserTextColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .userTextColor
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue.hexString(), forKey: uUserTextColor)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue.hexString(), forKey: uUserTextColor)
            }
        }
    }
    ///机器人聊天框字体颜色
    var botTextColor:UIColor {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uBotTextColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .botTextColor
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uBotTextColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .botTextColor
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue.hexString(), forKey: uBotTextColor)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue.hexString(), forKey: uBotTextColor)
            }
        }
    }
    
    //MARK: 波纹颜色
    ///波纹颜色
    var waveColor:UIColor {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uWaveColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .red
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uWaveColor) {
                    return UIColor(hexString: value as! String)!
                } else {
                    return .red
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue.hexString(), forKey: uWaveColor)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue.hexString(), forKey: uWaveColor)
            }
        }
    }

    //MARK: API相关
    ///机器人类型
    var aiModelType:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uAiModelType) {
                    return value as! String
                } else {
                    return "text-davinci-003"
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uAiModelType) {
                    return value as! String
                } else {
                    return "text-davinci-003"
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uAiModelType)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uAiModelType)
            }
        }
    }
    ///机器人Token
    var apiToken:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uTokenKey) {
                    return value as! String
                } else {
                    return ""
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uTokenKey) {
                    return value as! String
                } else {
                    return ""
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uTokenKey)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uTokenKey)
            }
        }
    }
    ///机器人智障程度
    var aiSmart:Double {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uAiSmart) {
                    return value as! Double
                } else {
                    return 0.2
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uAiSmart) {
                    return value as! Double
                } else {
                    return 0.2
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uAiSmart)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uAiSmart)
            }
        }
    }
    ///机器人画画尺寸
    var aiDrawSize:CGSize {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uAiDrawSize) {
                    return (try? CGSize.from(archivedData: value as! Data))!
                } else {
                    return CGSize(width: 1024, height: 1024)
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uAiDrawSize) {
                    return (try? CGSize.from(archivedData: value as! Data))!
                } else {
                    return CGSize(width: 1024, height: 1024)
                }
            }
        } set {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(data, forKey: uAiDrawSize)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(data, forKey: uAiDrawSize)
            }
        }
    }
    
    ///获取图片数量
    var getImageCount:Int {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uGetImageCount) {
                    return value as! Int
                } else {
                    return 1
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uGetImageCount) {
                    return value as! Int
                } else {
                    return 1
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uGetImageCount)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uGetImageCount)
            }
        }

    }
        
    //MARK: 语音输入语言
    ///语音输入语言
    var language:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uLanguageKey) {
                    return value as! String
                } else {
                    return OSSVoiceEnum.ChineseSimplified.rawValue
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uLanguageKey) {
                    return value as! String
                } else {
                    return OSSVoiceEnum.ChineseSimplified.rawValue
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uLanguageKey)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uLanguageKey)
            }
        }
    }
    
    //MARK: 聊天历史记录
    var segChatHistory:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uSegChatHistory) {
                    return value as! String
                } else {
                    let baseSub = PTSegHistoryModel()
                    baseSub.keyName = "Base"
                    let jsonArr = [baseSub.toJSON()!.toJSON()!]
                    let dataString = jsonArr.joined(separator: kSeparatorSeg)
                    return dataString
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uSegChatHistory) {
                    return value as! String
                } else {
                    let baseSub = PTSegHistoryModel()
                    baseSub.keyName = "Base"
                    let jsonArr = [baseSub.toJSON()!.toJSON()!]
                    let dataString = jsonArr.joined(separator: kSeparatorSeg)
                    return dataString
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uSegChatHistory)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uSegChatHistory)
            }
        }
    }
    
    func tagDataArr() -> [PTSegHistoryModel] {
        var arr = [PTSegHistoryModel]()
        if let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory {
            let dataArr = dataString.components(separatedBy: kSeparatorSeg)
            dataArr.enumerated().forEach { index,value in
                let model = PTSegHistoryModel.deserialize(from: value)
                arr.append(model!)
            }
            return arr
        }
        return arr
    }
    
    //MARK: 精选记录
    ///精选记录
    var chatFavourtie:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uSaveChat) {
                    return value as! String
                } else {
                    return ""
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uSaveChat) {
                    return value as! String
                } else {
                    return ""
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uSaveChat)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uSaveChat)
            }
        }
    }
    
    func mobileDataSavePlaceChange() {
        self.userIcon = self.userIcon
        self.userBubbleColor = self.userBubbleColor
        self.botBubbleColor = self.botBubbleColor
        self.userTextColor = self.userTextColor
        self.botTextColor = self.botTextColor
        self.waveColor = self.waveColor
        self.aiModelType = self.aiModelType
        self.apiToken = self.apiToken
        self.aiSmart = self.aiSmart
        self.aiDrawSize = self.aiDrawSize
        self.language = self.language
        self.chatFavourtie = self.chatFavourtie
        self.userIconURL = self.userIconURL
        self.segChatHistory = self.segChatHistory
    }

    lazy var languagePickerData:[String] = {
        var data = [String]()
        OSSVoiceEnum.allCases.enumerated().forEach { index,value in
            data.append(value.rawValue)
        }
        return data
    }()
    
    let imageSizeArray:[String] = {
        return ImageSize.allValues.map { $0.rawValue}
    }()
    
    let getImageCountPickerData:[String] = {
        var countString = [String]()
        for i in 1...10 {
            countString.append("\(i)")
        }
        return countString
    }()
    
    func getAIMpdelType(typeString:String) -> OpenAIModelType
    {
        if typeString == "text-davinci-003" {
            return OpenAIModelType.gpt3(.davinci)
        } else if typeString == "text-curie-001" {
            return OpenAIModelType.gpt3(.curie)
        } else if typeString == "text-babbage-001" {
            return OpenAIModelType.gpt3(.babbage)
        } else if typeString == "text-ada-001" {
            return OpenAIModelType.gpt3(.ada)
        } else if typeString == "code-davinci-002" {
            return OpenAIModelType.codex(.davinci)
        } else if typeString == "code-cushman-001" {
            return OpenAIModelType.codex(.cushman)
        } else if typeString == "text-davinci-edit-001" {
            return OpenAIModelType.feature(.davinci)
        } else if typeString == "gpt-3.5-turbo" {
            return OpenAIModelType.chat(.chatgpt)
        } else if typeString == "gpt-3.5-turbo-0301" {
            return OpenAIModelType.chat(.chatgpt0301)
        } else if typeString == "gpt-4" {
            return OpenAIModelType.chat(.chatgpt4)
        } else if typeString == "gpt-4-0314" {
            return OpenAIModelType.chat(.chatgpt40314)
        } else if typeString == "gpt-4-32k" {
            return OpenAIModelType.chat(.chatgpt432k)
        } else if typeString == "gpt-4-32k-0314" {
            return OpenAIModelType.chat(.chatgpt432k0314)
        } else {
            return OpenAIModelType.gpt3(.davinci)
        }
    }
    
    func getAiModelPickerDate(currentAi:String,currentChatModel:PTSegHistoryModel?,handle:@escaping (_ pickerArr:[BRResultModel],_ currentAiIndex:[NSNumber])->Void)
    {
        var modelArr = [BRResultModel]()
        
        if (currentChatModel?.systemContent ?? "").stringIsEmpty() {
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
        }
        
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

        let gptFourModel = BRResultModel()
        gptFourModel.parentKey = "GPTX"
        gptFourModel.parentValue = OpenAIModelType.chat(.chatgpt4).modelName
        gptFourModel.key = "3"
        gptFourModel.value = OpenAIModelType.chat(.chatgpt4).modelName
        modelArr.append(gptFourModel)

        let gptFour0314Model = BRResultModel()
        gptFour0314Model.parentKey = "GPTX"
        gptFour0314Model.parentValue = OpenAIModelType.chat(.chatgpt40314).modelName
        gptFour0314Model.key = "4"
        gptFour0314Model.value = OpenAIModelType.chat(.chatgpt40314).modelName
        modelArr.append(gptFour0314Model)

        let gptFour32kModel = BRResultModel()
        gptFour32kModel.parentKey = "GPTX"
        gptFour32kModel.parentValue = OpenAIModelType.chat(.chatgpt432k).modelName
        gptFour32kModel.key = "5"
        gptFour32kModel.value = OpenAIModelType.chat(.chatgpt432k).modelName
        modelArr.append(gptFour32kModel)

        let gptFour32k0314Model = BRResultModel()
        gptFour32k0314Model.parentKey = "GPTX"
        gptFour32k0314Model.parentValue = OpenAIModelType.chat(.chatgpt432k0314).modelName
        gptFour32k0314Model.key = "6"
        gptFour32k0314Model.value = OpenAIModelType.chat(.chatgpt432k0314).modelName
        modelArr.append(gptFour32k0314Model)

        var indexPath = [NSNumber]()
        if currentAi == "text-davinci-003" {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 0))
        } else if currentAi == "text-curie-001" {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 1))
        } else if currentAi == "text-babbage-001" {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 2))
        } else if currentAi == "text-ada-001" {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 3))
        } else if currentAi == "code-davinci-002" {
            indexPath.append(NSNumber(value: 1))
            indexPath.append(NSNumber(value: 0))
        } else if currentAi == "code-cushman-001" {
            indexPath.append(NSNumber(value: 1))
            indexPath.append(NSNumber(value: 1))
        } else if currentAi == "text-davinci-edit-001" {
            indexPath.append(NSNumber(value: 2))
            indexPath.append(NSNumber(value: 0))
        } else if currentAi == "gpt-3.5-turbo" {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 0))
        } else if currentAi == "gpt-3.5-turbo-0301" {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 1))
        } else if currentAi == "gpt-4" {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 2))
        } else if currentAi == "gpt-4-0314" {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 3))
        } else if currentAi == "gpt-4-32k" {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 4))
        } else if currentAi == "gpt-4-32k-0314" {
            indexPath.append(NSNumber(value: 3))
            indexPath.append(NSNumber(value: 5))
        } else {
            indexPath.append(NSNumber(value: 0))
            indexPath.append(NSNumber(value: 0))
        }

        handle(modelArr,indexPath)
    }
    
    //MARK: 精选数据
    ///精选数据
    func getSaveChatData() -> [PTFavouriteModel]
    {
        var saveChatModel = [PTFavouriteModel]()
        if !self.chatFavourtie.stringIsEmpty()
        {
            let userModelsStringArr = self.chatFavourtie.components(separatedBy: kSeparator)
            userModelsStringArr.enumerated().forEach { index,value in
                let models = PTFavouriteModel.deserialize(from: value)
                saveChatModel.append(models!)
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
        style.cancelTextFont = .appfont(size: 15)
        let cancelW = UIView.sizeFor(string: PTLanguage.share.text(forKey: "button_Cancel"), font: .appfont(size: 16), height: style.cancelBtnFrame.size.height, width: CGFloat(MAXFLOAT)).width + 10
        style.cancelBtnTitle = PTLanguage.share.text(forKey: "button_Cancel")
        style.cancelBtnFrame = CGRectMake(style.cancelBtnFrame.origin.x, style.cancelBtnFrame.origin.y, cancelW, style.cancelBtnFrame.size.height)
        style.cancelTextColor = .systemBlue
        style.doneTextFont = .appfont(size: 15)
        style.doneBtnTitle = PTLanguage.share.text(forKey: "button_Confirm")
        let doneW = UIView.sizeFor(string: PTLanguage.share.text(forKey: "button_Confirm"), font: .appfont(size: 16), height: style.doneBtnFrame.size.height, width: CGFloat(MAXFLOAT)).width + 10
        style.doneBtnFrame = CGRectMake(CGFloat.kSCREEN_WIDTH - doneW, style.doneBtnFrame.origin.y, doneW, style.doneBtnFrame.size.height)
        style.doneTextColor = .systemBlue
        return style
    }

    class func refreshTagData(segDataArr:[PTSegHistoryModel])
    {
        var stringArr = [String]()
        segDataArr.enumerated().forEach { index,value in
            stringArr.append(value.toJSON()!.toJSON()!)
        }
        AppDelegate.appDelegate()!.appConfig.segChatHistory = stringArr.joined(separator: kSeparatorSeg)
    }
}

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
import OSSSpeechKit

//“$0.002 per 1k tokens”

///用戶的BubbleColor key
let uUserBubbleColor = "uUserBubbleColor"
///機器人的BubbleColor key
let uBotBubbleColor = "uBotBubbleColor"
///用戶的TextColor key
let uUserTextColor = "uUserTextColor"
///機器人的TextColor key
let uBotTextColor = "uBotTextColor"
///Seg控制器的历史记录Key
let uSegChatHistorySaved = "uSegChatHistorySaved"
let uUserCurrentTag = "uUserCurrentTag"
///保存記錄 key
let uSaveChatSaved = "uSaveChatSaved"
///保存的機器人類型
let uAiModelType = "uAiModelType"
///保存的機器人智障程度
let uAiSmart = "uAiSmart"
///保存的用戶的頭像
let uUserIcon = "uUserIcon"
let uUserIconURL = "uUserIconURL"
let uDrawRefrence = "uDrawRefrence"
let uUserName = "uUserName"
let uAiName = "uAiName"
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
///使用iCloud
let uUseiCloud = "uUseiCloud"
///第一次使用App提示
let uFirstCoach = "uFirstCoach"
///图片数量Key
let uGetImageCount = "uGetImageCount"

let uCheckSentence = "uCheckSentence"

let uAppCount = "uAppCount"

//MARK: 总共用了多少Token
let uTotalToken = "uTotalToken"
let uTotalTokenCost = "uTotalTokenCost"

///是否用自定义域名
let uUseCustomDomain = "uUseCustomDomain"
///自定义域名
let uCustomDomain = "uCustomDomain"

let uAppBuildVersion = "uAppBuildVersion"

let nSetKey = "nSetKey"
let nPadReloadKey = "nPadReloadKey"

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

//MARK: 图片保存的本地地址
let userImageMessageFilePath = FileManager.pt.LibraryDirectory() + "/UserImageMessageFile"
//MARK: 聊天记录保存的本地地址
let userChatMessageFilePath = FileManager.pt.LibraryDirectory() + "/UserChatMessageFile"
//MARK: Token消费记录保存的本地地址
let userChatCostFilePath = FileManager.pt.LibraryDirectory() + "/UserChatCostFile"

let uploadFilePath = FileManager.pt.LibraryDirectory() + "/UploadFile"

let iPadSplitMainControl:CGFloat = 300

extension UIColor {
    static let botBubbleColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    static let userBubbleColor = UIColor.systemBlue
    
    static let userTextColor = UIColor.darkText
    static let botTextColor = UIColor.darkText
    /// 字體顏色
    private(set) static var gobalTextColor = PTDarkModeOption.colorLightDark(lightColor: .black, darkColor: UIColor.white)
    private(set) static var gobalBackgroundColor = PTDarkModeOption.colorLightDark(lightColor: PTAppBaseConfig.share.viewControllerBaseBackgroundColor, darkColor: UIColor.black)
    
    private(set) static var gobalScrollerBackgroundColor = PTDarkModeOption.colorLightDark(lightColor: PTAppBaseConfig.share.viewControllerBaseBackgroundColor, darkColor: UIColor.black)
    
    private(set) static var gobalCellBackgroundColor = PTDarkModeOption.colorLightDark(lightColor: .white, darkColor: .Black25PercentColor)
}

extension String {
    static let findImage = PTLanguage.share.text(forKey: "chat_Looking_for")
    static let remakeImage = PTLanguage.share.text(forKey: "chat_Paint_image")
    
    func replaceStringWithAsterisk() -> String {
        let nsString = self.nsString
        let pattern = "." // 正则表达式匹配所有字符
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSMakeRange(0, nsString.length)
        let mutableStr = NSMutableString(string: self)
        regex.replaceMatches(in: mutableStr, options: .reportCompletion, range: range, withTemplate: "*")
        return String(mutableStr)
    }
}

class PTAppConfig {
    static let share = PTAppConfig()
        
    var currentSelectTag:String = UserDefaults.standard.value(forKey: uUserCurrentTag) == nil ? "Base" : UserDefaults.standard.value(forKey: uUserCurrentTag) as! String {
        didSet{
            UserDefaults.standard.set(self.currentSelectTag,forKey: uUserCurrentTag)
        }
    }
    
    var appCount:Int = UserDefaults.standard.value(forKey: uAppCount) == nil ? 1 : UserDefaults.standard.value(forKey: uAppCount) as! Int {
        didSet{
            UserDefaults.standard.set(self.appCount,forKey: uAppCount)
        }
    }
        
    var firstCoach:Bool = UserDefaults.standard.value(forKey: uFirstCoach) == nil ? true : UserDefaults.standard.value(forKey: uFirstCoach) as! Bool {
        didSet{
            UserDefaults.standard.set(self.firstCoach,forKey: uFirstCoach)
        }
    }
        
    var firstUseApp:Bool = UserDefaults.standard.value(forKey: uAppFirstUse) == nil ? true : UserDefaults.standard.value(forKey: uAppFirstUse) as! Bool {
        didSet{
            UserDefaults.standard.set(self.firstUseApp,forKey: uAppFirstUse)
        }
    }
    
    var cloudSwitch:Bool = UserDefaults.standard.value(forKey: uUseiCloud) == nil ? true : UserDefaults.standard.value(forKey: uUseiCloud) as! Bool {
        didSet{
            UserDefaults.standard.set(self.cloudSwitch,forKey: uUseiCloud)
        }
    }
    
    //MARK: 是否开启自定义域名
    ///是否开启自定义域名
    var useCustomDomain:Bool {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uUseCustomDomain) {
                    return value as! Bool
                } else {
                    return false
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uUseCustomDomain) {
                    return value as! Bool
                } else {
                    return false
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uUseCustomDomain)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uUseCustomDomain)
            }
        }
    }
    
    var customDomain:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uCustomDomain) {
                    return value as! String
                } else {
                    return ""
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uCustomDomain) {
                    return value as! String
                } else {
                    return ""
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uCustomDomain)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uCustomDomain)
            }
        }
    }
    
    //MARK: 是否开启绿色模式
    ///是否开启绿色模式
    var checkSentence:Bool {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uCheckSentence) {
                    return value as! Bool
                } else {
                    return false
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uCheckSentence) {
                    return value as! Bool
                } else {
                    return false
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uCheckSentence)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uCheckSentence)
            }
        }
    }
    
    //MARK: 用户名字
    ///用户名字
    var userName:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uUserName) {
                    return value as! String
                } else {
                    return PTLanguage.share.text(forKey: "chat_User")
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uUserName) {
                    return value as! String
                } else {
                    return PTLanguage.share.text(forKey: "chat_User")
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uUserName)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uUserName)
            }
        }
    }
    
    //MARK: AI名字
    ///AI名字
    var aiName:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uAiName) {
                    return value as! String
                } else {
                    return "ZolaAi"
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uAiName) {
                    return value as! String
                } else {
                    return "ZolaAi"
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uAiName)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uAiName)
            }
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
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
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
                    } catch let error {
                        PTNSLogConsole("Failed to write image data to iCloud: \(error.localizedDescription)")
                    }
                }
            } else {
                UserDefaults.standard.set(newValue, forKey: uUserIcon)
            }
        }
    }
    ///油畫圖片Data
    var drawRefrence:Data {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let imageURL = icloudURL.appendingPathComponent("drawRefrence.png")
                    if let imageData = try? Data(contentsOf: imageURL) {
                        return imageData
                    } else {
                        return UIImage(named: "DemoImage")!.pngData()!
                    }
                } else {
                    return UIImage(named: "DemoImage")!.pngData()!
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uDrawRefrence) {
                    return value as! Data
                } else {
                    return UIImage(named: "DemoImage")!.pngData()!
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let imageURL = icloudURL.appendingPathComponent("drawRefrence.png")
                    do {
                        try newValue.write(to: imageURL, options: .atomic)
                    } catch let error {
                        PTNSLogConsole("Failed to write image data to iCloud: \(error.localizedDescription)")
                    }
                }
            } else {
                UserDefaults.standard.set(newValue, forKey: uDrawRefrence)
            }
        }
    }
    
    ///保存聊天的圖片到iCloud
    func saveUserSendImage(image:UIImage,fileName:String,jobDoneBlock:@escaping ((_ finish:Bool)->Void)) {
        if self.cloudSwitch {
            if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                let imageURL = iCloudURL.appendingPathComponent(fileName)
                Task.init {
                    do {
                        try image.pngData()!.write(to: imageURL,options: .atomic)
                        jobDoneBlock(true)
                    } catch {
                        PTNSLogConsole("Failed to write image data to iCloud: \(error.localizedDescription)")
                        jobDoneBlock(false)
                    }
                }
            }
        } else {
            let filePath = userImageMessageFilePath.appending("/\(fileName)")
            let fileURL = URL(fileURLWithPath: filePath)
            Task.init {
                do {
                    try image.pngData()!.write(to: fileURL)
                    jobDoneBlock(true)
                } catch {
                    PTNSLogConsole("Failed to write image data to path: \(error.localizedDescription)")
                    jobDoneBlock(false)
                }
            }
        }
    }
    
    func getMessageImagePath(name:String) -> URL {
        if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
            if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                let imageURL = icloudURL.appendingPathComponent(name)
                return imageURL
            } else {
                return URL(string: "")!
            }
        } else {
            let imageURL = userImageMessageFilePath + "/\(name)"
            return URL(fileURLWithPath: imageURL)
        }
    }
    
    func getMessageImage(name:String) -> UIImage {
        let filePath = self.getMessageImagePath(name: name)
        if let image = try? Data(contentsOf: filePath) {
            return UIImage(data: image)!
        } else {
            return UIImage()
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
                    return 1
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uAiSmart) {
                    return value as! Double
                } else {
                    return 1
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
    var setChatData:[[String:Any]] {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let imageURL = icloudURL.appendingPathComponent("SetChatJson.json")
                    do {
                        let jsonData = try Data(contentsOf: imageURL,options: .mappedIfSafe)
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                        return json as! [[String : Any]]
                    } catch {
                        
                        let baseSub = PTSegHistoryModel()
                        baseSub.keyName = "Base"
                        
                        let createBaseData = baseSub.toJSON()!
                        
                        self.setChatData = [createBaseData]
                        
                        return [createBaseData]
                    }
                } else {
                    let baseSub = PTSegHistoryModel()
                    baseSub.keyName = "Base"
                    
                    let createBaseData = baseSub.toJSON()!
                    
                    self.setChatData = [createBaseData]

                    return [createBaseData]
                }
            } else {
                let filePath = userChatMessageFilePath.appending("/SetChatJson.json")
                let fileURL = URL(fileURLWithPath: filePath)

                do {
                    let jsonData = try Data(contentsOf: fileURL,options: .mappedIfSafe)
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                    return json as! [[String : Any]]
                } catch {
                    let baseSub = PTSegHistoryModel()
                    baseSub.keyName = "Base"
                    
                    let createBaseData = baseSub.toJSON()!
                    
                    self.setChatData = [createBaseData]

                    return [createBaseData]
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let chatJsonURL = icloudURL.appendingPathComponent("SetChatJson.json")
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                        try jsonData.write(to: chatJsonURL, options: .atomic)
                        self.segChatHistorySaved = "1"
                    } catch let error {
                        PTNSLogConsole("Failed to write json data to iCloud: \(error.localizedDescription)")
                    }
                }
            } else {
                do {
                    let filePath = userChatMessageFilePath.appendingPathComponent("SetChatJson.json")
                    if FileManager.pt.judgeFileOrFolderExists(filePath: filePath) {
                        let fileURL = URL(fileURLWithPath: filePath)
                        let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                        try jsonData.write(to: fileURL)
                    } else {
                        let result = FileManager.pt.createFile(filePath: filePath)
                        if result.isSuccess {
                            let fileURL = URL(fileURLWithPath: filePath)
                            let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                            try jsonData.write(to: fileURL)
                            self.segChatHistorySaved = "1"
                        } else {
                            PTNSLogConsole("Failed to write json data to local: \(result.error)")
                        }
                    }
                } catch {
                    PTNSLogConsole("Failed to write json data to local: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var segChatHistorySaved:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uSegChatHistorySaved) {
                    return value as! String
                } else {
                    return ""
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uSegChatHistorySaved) {
                    return value as! String
                } else {
                    return ""
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uSegChatHistorySaved)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uSegChatHistorySaved)
            }
        }
    }
    
    func tagDataArr() -> [PTSegHistoryModel?] {
        if let models = [PTSegHistoryModel].deserialize(from: self.setChatData) {
            return models
        } else {
            return [PTSegHistoryModel?]()
        }
    }
    
    //MARK: 精选记录
    ///精选记录
    var favouriteChat:[[String:Any]] {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let imageURL = icloudURL.appendingPathComponent("FavouriteChat.json")
                    do {
                        let jsonData = try Data(contentsOf: imageURL,options: .mappedIfSafe)
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                        return json as! [[String : Any]]
                    } catch {
                        return [[String:Any]]()
                    }
                } else {
                    return [[String:Any]]()
                }
            } else {
                let filePath = userChatMessageFilePath.appending("/FavouriteChat.json")
                let fileURL = URL(fileURLWithPath: filePath)

                do {
                    let jsonData = try Data(contentsOf: fileURL,options: .mappedIfSafe)
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                    return json as! [[String : Any]]
                } catch {
                    return [[String:Any]]()
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let chatJsonURL = icloudURL.appendingPathComponent("FavouriteChat.json")
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                        try jsonData.write(to: chatJsonURL, options: .atomic)
                        self.chatFavourtieSaved = "1"
                    } catch let error {
                        PTNSLogConsole("Failed to write json data to iCloud: \(error.localizedDescription)")
                    }
                }
            } else {
                do {
                    let filePath = userChatMessageFilePath.appendingPathComponent("FavouriteChat.json")
                    if FileManager.pt.judgeFileOrFolderExists(filePath: filePath) {
                        let fileURL = URL(fileURLWithPath: filePath)
                        let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                        try jsonData.write(to: fileURL)
                    } else {
                        let result = FileManager.pt.createFile(filePath: filePath)
                        if result.isSuccess {
                            let fileURL = URL(fileURLWithPath: filePath)
                            let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                            try jsonData.write(to: fileURL)
                            self.chatFavourtieSaved = "1"
                        } else {
                            PTNSLogConsole("Failed to write json data to local: \(result.error)")
                        }
                    }
                } catch {
                    PTNSLogConsole("Failed to write json data to local: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var chatFavourtieSaved:String {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uSaveChatSaved) {
                    return value as! String
                } else {
                    return ""
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uSaveChatSaved) {
                    return value as! String
                } else {
                    return ""
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uSaveChatSaved)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uSaveChatSaved)
            }
        }
    }
    
    //MARK: 精选数据
    ///精选数据
    func getSaveChatData() -> [PTFavouriteModel?] {
        if let models = [PTFavouriteModel].deserialize(from: self.favouriteChat) {
            return models
        } else {
            return [PTFavouriteModel?]()
        }
    }
    
    var totalToken:Double {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uTotalToken) {
                    return value as! Double
                } else {
                    return 0
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uTotalToken) {
                    return value as! Double
                } else {
                    return 0
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uTotalToken)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uTotalToken)
            }
        }
    }
    
    var totalTokenCost:Double {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let value = AppDelegate.appDelegate()?.cloudStore.object(forKey: uTotalTokenCost) {
                    return value as! Double
                } else {
                    return 0
                }
            } else {
                if let value = UserDefaults.standard.value(forKey: uTotalTokenCost) {
                    return value as! Double
                } else {
                    return 0
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                AppDelegate.appDelegate()?.cloudStore.set(newValue, forKey: uTotalTokenCost)
                AppDelegate.appDelegate()?.cloudStore.synchronize()
            } else {
                UserDefaults.standard.set(newValue, forKey: uTotalTokenCost)
            }
        }
    }
    
    //MARK: 花费记录
    var costHistory:[[String:Any]] {
        get {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let fileURL = icloudURL.appendingPathComponent("CostHistoria.json")
                    do {
                        let jsonData = try Data(contentsOf: fileURL,options: .mappedIfSafe)
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                        return json as! [[String : Any]]
                    } catch {
                        return [[String : Any]]()
                    }
                } else {
                    return [[String : Any]]()
                }
            } else {
                let filePath = userChatCostFilePath.appending("/CostHistoria.json")
                let fileURL = URL(fileURLWithPath: filePath)

                do {
                    let jsonData = try Data(contentsOf: fileURL,options: .mappedIfSafe)
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                    return json as! [[String : Any]]
                } catch {
                    return [[String : Any]]()
                }
            }
        } set {
            if AppDelegate.appDelegate()!.appConfig.cloudSwitch {
                if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    let chatJsonURL = icloudURL.appendingPathComponent("CostHistoria.json")
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                        try jsonData.write(to: chatJsonURL, options: .atomic)
                    } catch let error {
                        PTNSLogConsole("Failed to write json data to iCloud: \(error.localizedDescription)")
                    }
                }
            } else {
                do {
                    let filePath = userChatCostFilePath.appendingPathComponent("CostHistoria.json")
                    if FileManager.pt.judgeFileOrFolderExists(filePath: filePath) {
                        let fileURL = URL(fileURLWithPath: filePath)
                        let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                        try jsonData.write(to: fileURL)
                    } else {
                        let result = FileManager.pt.createFile(filePath: filePath)
                        if result.isSuccess {
                            let fileURL = URL(fileURLWithPath: filePath)
                            let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                            try jsonData.write(to: fileURL)
                        } else {
                            PTNSLogConsole("Failed to write json data to local: \(result.error)")
                        }
                    }
                } catch {
                    PTNSLogConsole("Failed to write json data to local: \(error.localizedDescription)")
                }
            }
        }
    }

    //MARK: 精选数据
    ///精选数据
    func getCostHistoriaData() -> [PTCostMainModel?] {
        if let models = [PTCostMainModel].deserialize(from: self.costHistory) {
            return models
        } else {
            return [PTCostMainModel?]()
        }
    }
    
    //MARK: 下载记录
    var downloadInfomation:[[String:Any]] {
        get {
            let filePath = FileManager.pt.TmpDirectory().appendingPathComponent("AIModelJson.json")
            let fileURL = URL(fileURLWithPath: filePath)

            do {
                let jsonData = try Data(contentsOf: fileURL,options: .mappedIfSafe)
                let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                return json as! [[String : Any]]
            } catch {

                let modi = PTDownloadModelModel()
                modi.name = "MoDi"
                modi.url = "https://iphj6g.ch.files.1drv.com/y4mOzzLFLtDYYk3pyVUTHyrafIsOzbjHxr1DE1GUWJ8zAoL9WiwlPvMpQFj6CrhbjBo1Mp5rvO1LalLWmTNF4SrbaDNXPEJwGTtFlUXMFyFrtYWXfXHkjw9Ojdq-3MmyuinHV6yGaADPh708EgZdK8NeN6AKcwpRMfxelui3SCmvFMEitkjA8N1hUdvx1IvSdn9ik86Lg5vb-9IJz_dT04TCQ"
                modi.folderName = "bins_cartoon"
                
                let model1_4 = PTDownloadModelModel()
                model1_4.name = "V1.4"
                model1_4.url = "https://vlvxjq.ch.files.1drv.com/y4mmhEzgftFiI8HsW7N3M3NIr7ZzJ3gV37H7rJKgZT-AI1uXfSUFz09eipBxKnXgLMQ617IAZ9yN3jqJlnYsDwqj1uB4jaTuG4_NZJ8BTXNw2RoW8IiDtyO1aVkPk97sOvmONW86Dle-1z0c1eQIyqMUrMnssFo1Q6owkNP4NpiMOj4hRVGDpl7YHyEIW8a1PT32hxS-cnnjK5CtD4z0OiIdQ"
                model1_4.folderName = "bins1_4"

                let model1_5 = PTDownloadModelModel()
                model1_5.name = "V1.5"
                model1_5.url = "https://wcoyma.ch.files.1drv.com/y4mOdda6SfhrNB_h8hCJl3LDtq1i4M-ILTl0z9_0S78xLjCqhUntyGCHs6EJdfZQ3K92pw4Qd04EIznvAq5QVxJLYlrjaj34jpAUL-m3SvnTIkFBcbbaITo7obii1rJw7TammE4LA1P4OwavpgfDMS7lnnYmONISarnHWThm5Qh1Obl-se1hT-sIukwtWzWhDs5jvo94csyg--yXR2MU0pxeA"
                model1_5.folderName = "bins1_5"

                let modelTest = PTDownloadModelModel()
                modelTest.name = "TEST"
                modelTest.url = "https://9d7a0g.ch.files.1drv.com/y4mYr491C4NT_VEphAv_VLrRSrNVdTx3Qc2LPE2aA3HQeSwxNULfuBZMKCMPJoQR8ycJtunyaBHgPsABkNXzW0p9P6IIz2G5hdM5yNmRp44EUolJQf2oqmUNZXQHpXbhkGb_ab708MFVkf-KMWQRCq29GymC_Oje7PFk7Ow_ulRuJMDIEfdyLmIveffvW8QjlGKnXjc5meVut_GUCJ9mchQiA"
                modelTest.folderName = "JKSwiftExtension-master"
           
                var packData = [[String:Any]]()
                
                if self.canUseStableDiffusionModel() {
                    packData = [modi.toJSON()!,model1_4.toJSON()!,model1_5.toJSON()!,modelTest.toJSON()!]
                } else {
                    packData = [modi.toJSON()!,model1_4.toJSON()!,model1_5.toJSON()!]
                }
                self.downloadInfomation = packData

                return packData
            }
        } set {
            do {
                
                let filePath = FileManager.pt.TmpDirectory().appendingPathComponent("AIModelJson.json")
                let fileURL = URL(fileURLWithPath: filePath)
                let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                try jsonData.write(to: fileURL)
            } catch {
                PTNSLogConsole("Have file failed to write json data to local: \(error.localizedDescription)")
            }
        }
    }

    //MARK: 获取下载模型信息
    ///获取下载模型信息
    func getDownloadInfomation() -> [PTDownloadModelModel?] {
        if let models = [PTDownloadModelModel].deserialize(from: self.downloadInfomation) {
            
            if models.count > 0 {
                for (index,value) in models.enumerated() {
                    if !FileManager.pt.judgeFileOrFolderExists(filePath: uploadFilePath.appendingPathComponent(value!.folderName)) {
                        models[index]?.loadFinish = false
                    } else {
                        models[index]?.loadFinish = true
                    }
                }
                self.downloadInfomation = models.kj.JSONObjectArray()
                if let newModels = [PTDownloadModelModel].deserialize(from: self.downloadInfomation) {
                    return newModels
                }
            }
            return models
        } else {
            return [PTDownloadModelModel?]()
        }
    }
    
    let imageControlActions:[String] = {
        return [.findImage,.remakeImage]
    }()
    
    func mobileDataSavePlaceChange(value:Bool) {
        let userIcon = self.userIcon
        let userBubbleColor = self.userBubbleColor
        let botBubbleColor = self.botBubbleColor
        let userTextColor = self.userTextColor
        let botTextColor = self.botTextColor
        let waveColor = self.waveColor
        let aiModelType = self.aiModelType
        let apiToken = self.apiToken
        let aiSmart = self.aiSmart
        let aiDrawSize = self.aiDrawSize
        let language = self.language
        let chatFavourtie = self.favouriteChat
        let userIconURL = self.userIconURL
        let drawRefrence = self.drawRefrence
        let getImageCount = self.getImageCount
        let checkSentence = self.checkSentence
        let setChatData = self.setChatData
        let totalToken = self.totalToken
        AppDelegate.appDelegate()?.appConfig.cloudSwitch = value
        PTGCDManager.gcdAfter(time: 0.35) {
            self.userIcon = userIcon
            self.userBubbleColor = userBubbleColor
            self.botBubbleColor = botBubbleColor
            self.userTextColor = userTextColor
            self.botTextColor = botTextColor
            self.waveColor = waveColor
            self.aiModelType = aiModelType
            self.apiToken = apiToken
            self.aiSmart = aiSmart
            self.aiDrawSize = aiDrawSize
            self.language = language
            self.favouriteChat = chatFavourtie
            self.userIconURL = userIconURL
            self.drawRefrence = drawRefrence
            self.getImageCount = getImageCount
            self.checkSentence = checkSentence
            self.setChatData = setChatData
            self.totalToken = totalToken
        }
    }
    
    func mobileDataReset(delegate: OSSSpeechDelegate,resetSetting:@escaping (()->Void),resetChat:@escaping (()->Void),resetVoiceFile:@escaping (()->Void),resetImage:@escaping (()->Void)) {
        PTGCDManager.gcdAfter(time: 1) {
            //主題
            self.userIcon = UIImage(named: "DemoImage")!.pngData()!
            self.userBubbleColor = .userBubbleColor
            self.botBubbleColor = .botBubbleColor
            self.userTextColor = .userTextColor
            self.botTextColor = .botTextColor
            self.waveColor = .red
            //Speech
            self.language = OSSVoiceEnum.ChineseSimplified.rawValue
            //Chat
            self.favouriteChat = [[String:Any]]()
            //AI
            self.aiModelType = "text-davinci-003"
            self.aiSmart = 1
            self.aiDrawSize = CGSize(width: 1024, height: 1024)
            self.getImageCount = 1
            self.drawRefrence = UIImage(named: "DemoImage")!.pngData()!
            
            resetSetting()
            
            PTGCDManager.gcdAfter(time: 1.5) {
                let baseSub = PTSegHistoryModel()
                baseSub.keyName = "Base"
                let createBaseData = baseSub.toJSON()!
                self.setChatData = [createBaseData]
                self.favouriteChat = [[String:Any]]()
                resetChat()
                
                PTGCDManager.gcdAfter(time: 1) {
                    let speechKit = OSSSpeech.shared
                    speechKit.delegate = delegate
                    speechKit.deleteVoiceFolderItem(url: nil)
                    
                    resetVoiceFile()
                    PTGCDManager.gcdAfter(time: 1) {
                        if self.cloudSwitch {
                            let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
                            
                            if let contents = try? FileManager.default.contentsOfDirectory(at: iCloudURL!, includingPropertiesForKeys: nil, options: []) {
                                for (fileUrl) in contents {
                                    try? FileManager.default.removeItem(at: fileUrl)
                                }
                            }
                            PTGCDManager.gcdAfter(time: 3) {
                                resetImage()
                            }
                        } else {
                            FileManager.pt.removefolder(folderPath: userImageMessageFilePath)
                            PTGCDManager.gcdAfter(time: 3) {
                                resetImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    lazy var languagePickerData:[String] = {
        var data = [String]()
        OSSVoiceEnum.allCases.enumerated().forEach { index,value in
            data.append(value.rawValue)
        }
        return data
    }()
    
    let imageSizeArray:[String] = {
        return PTOpenAIImageSize.allValues.map { $0.rawValue}
    }()
    
    let getImageCountPickerData:[String] = {
        var countString = [String]()
        for i in 1...10 {
            countString.append("\(i)")
        }
        return countString
    }()
    
    func getAIMpdelType(typeString:String) -> OpenAIModelType {
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
    
    func getAiModelPickerDate(currentAi:String,currentChatModel:PTSegHistoryModel?,handle:@escaping (_ pickerArr:[BRResultModel],_ currentAiIndex:[NSNumber])->Void) {
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
    
    class open func gobal_BRPickerStyle()->BRPickerStyle {
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
    
    class func refreshTagData(segDataArr:[PTSegHistoryModel?]) {
        AppDelegate.appDelegate()!.appConfig.setChatData = segDataArr.kj.JSONObjectArray()
    }
    
    func getJsonFileTags() -> [String] {
        if let jsonData = self.loadJSON(fileName: "SampleJson") {
            var array = [String]()
            let models = [PTSampleMainModels].deserialize(from: (jsonData["result"] as! NSArray))
            models!.enumerated().forEach({ index,value in
                array.append(value!.segmentName)
            })
            return array
        }
        return []
    }
    
    func getJsonFileModel(index:Int) -> [PTSampleModels] {
        if let jsonData = self.loadJSON(fileName: "SampleJson") {
            var array = [PTSampleModels]()
            let models = [PTSampleMainModels].deserialize(from: (jsonData["result"] as! NSArray))
            let subModels = models![index]
            subModels?.persion.enumerated().forEach({ index,value in
                let subModel = value
                subModel.imported = self.tagDataArr().contains(where: {$0!.keyName == value.keyName && $0!.systemContent == value.systemContent})
                array.append(subModel)
            })
            return array
        }
        return [PTSampleModels]()
    }
    
    func loadJSON(fileName: String) -> [String: Any]? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                return json as? [String: Any]
            } catch {
                PTNSLogConsole("Error reading JSON file: \(error)")
            }
        }
        return nil
    }
    
    //MARK: AI定價
    func tokenCostImageCalculation(imageCount:Int) -> Double {
        var imageCost:Double = 0
        switch AppDelegate.appDelegate()!.appConfig.aiDrawSize.width {
        case 1024:
            imageCost = Double(imageCount) * 0.02
        case 512:
            imageCost = Double(imageCount) * 0.018
        case 256:
            imageCost = Double(imageCount) * 0.016
        default:
            imageCost = Double(imageCount) * 0.016
        }
        return imageCost
    }
    
    func tokenCostCalculation(type:OpenAIModelType,usageModel:PTReceiveChatUsage) -> Double {
        //https://openai.com/pricing
        var result:Double = 0
        switch type {
        case .chat(.chatgpt432k),.chat(.chatgpt432k0314):
            result = (0.03 / 1000 * Double(usageModel.prompt_tokens) + 0.06 / 1000 * Double(usageModel.completion_tokens))
        case .chat(.chatgpt4),.chat(.chatgpt40314):
            result = (0.06 / 1000 * Double(usageModel.prompt_tokens) + 0.12 / 1000 * Double(usageModel.completion_tokens))
        case .chat(.chatgpt),.chat(.chatgpt0301):
            result = (0.002 / 1000 * Double(usageModel.total_tokens))
        case .gpt3(.ada):
            result = (0.0004 / 1000 * Double(usageModel.total_tokens))
        case .gpt3(.babbage):
            result = (0.0005 / 1000 * Double(usageModel.total_tokens))
        case .gpt3(.curie):
            result = (0.002 / 1000 * Double(usageModel.total_tokens))
        case .gpt3(.davinci):
            result = (0.02 / 1000 * Double(usageModel.total_tokens))
        default:break
        }
        return result
    }

    //MARK: 是否能使用AI
    func canUseStableDiffusionModel() -> Bool {
        if UIApplication.applicationEnvironment() == .appStore || UIApplication.applicationEnvironment() == .testFlight {
            if Gobal_device_info.isOneOf([.iPhone13Pro,.iPhone13ProMax,.iPhone14Pro,.iPhone14ProMax, .iPadPro10Inch, .iPadPro11Inch, .iPadPro12Inch3, .iPadPro12Inch4, .iPadPro11Inch3, .iPadPro12Inch5, .iPadPro11Inch4, .iPadPro12Inch6,.iPadAir5,.iPadPro12Inch]) || Gobal_device_info.isSimulator {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}

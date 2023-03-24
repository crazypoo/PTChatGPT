//
//  AppDelegate.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import PooTools
#if DEBUG
import YCSymbolTracker
#if canImport(FLEX)
import FLEX
#endif
#if canImport(InAppViewDebugger)
import InAppViewDebugger
#endif
#endif
import Bugly

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var devFunction:PTDevFunction = PTDevFunction()
    
    let appConfig = PTAppConfig.share
    let cloudStore = NSUbiquitousKeyValueStore.default
    let query = NSMetadataQuery()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        FileManager.pt.createFolder(folderPath: userImageMessageFilePath)

        if self.appConfig.firstDataChange {
            let baseSub = PTSegHistoryModel()
            baseSub.keyName = "Base"
            let jsonArr = [baseSub.toJSON()!.toJSON()!]
            let dataString = jsonArr.joined(separator: kSeparatorSeg)
            self.appConfig.segChatHistory = dataString
            
            self.appConfig.firstDataChange = false
        }
        
        var debugDevice = false
        let buglyConfig = BuglyConfig()
//        buglyConfig.delegate = self
        #if DEBUG
        debugDevice = true
        buglyConfig.debugMode = true
        #endif
        buglyConfig.channel = "iOS"
        buglyConfig.blockMonitorEnable = true
        buglyConfig.blockMonitorTimeout = 2
        buglyConfig.consolelogEnable = false
        buglyConfig.viewControllerTrackingEnable = false
        Bugly.start(withAppId: "2553484f4b",
                    developmentDevice: debugDevice,
                    config: buglyConfig)

        PTDrakModeOption.defaultDark()
        PTAppBaseConfig.share.decorationBackgroundColor = .gobalCellBackgroundColor
        StatusBarManager.shared.isHidden = false
        StatusBarManager.shared.style = PTDrakModeOption.isLight ? .darkContent : .lightContent
        
        self.query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        self.query.predicate = NSPredicate(value: true)

        NotificationCenter.default.addObserver(self, selector: #selector(keyValueStoreDidChange(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: self.cloudStore)

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: AppDelegate.appDelegate()?.query, queue: nil) { (notification) in
            guard let query = notification.object as? NSMetadataQuery else {
                return
            }
            query.disableUpdates()
            let results = query.results
            if let fileURL = (results.first as? NSMetadataItem)?.value(forAttribute: NSMetadataItemURLKey) as? URL {
                if let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) {
                    // 成功读取图片数据
                    PTNSLogConsole("?>>>>????>>>>>\(image)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
                } else {
                    PTNSLogConsole("Failed to read image data from iCloud")
                }
                PTNSLogConsole("刷新\(fileURL)")
                // 文件存在，可以读取
            }
            query.stop()
        }
        
        if self.appConfig.firstUseiCloud {
            self.saveDataToCloud()
        }
        
        #if DEBUG
        let filePath = NSTemporaryDirectory().appending("/demo.order")
        YCSymbolTracker.exportSymbols(filePath: filePath)
        #endif
                        
        PTNSLogConsole("\(self.appConfig.apiToken)")
        var viewC:UIViewController!
        if self.appConfig.apiToken.stringIsEmpty()
        {
            viewC = PTSettingViewController()
        }
        else
        {
            PTNSLogConsole(self.appConfig.segChatHistory)
            viewC = PTChatViewController(historyModel: PTSegHistoryModel())//PTChatViewController(token: self.appConfig.apiToken,language: OSSVoiceEnum(rawValue: self.appConfig.language)!)
        }
        let nav = PTNavController(rootViewController: viewC)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        PTLaunchAdMonitor.showAt(path: ["https://avatars.githubusercontent.com/u/1111976?v=4"], onView: self.window!, timeInterval: 2, param: ["URLS":myGithubUrl], year: "2023", skipFont: .appfont(size: 10), comName: "Crazypoo", comNameFont: .appfont(size: 10)) {
        }

#if DEBUG
        self.devFunction.createLabBtn()
        self.devFunction.goToAppDevVC = {
            let vc = PTDebugViewController()
            let nav = UINavigationController(rootViewController: vc)
            PTUtils.getCurrentVC().present(nav, animated: true)
        }
        self.devFunction.flex = {
            if FLEXManager.shared.isHidden
            {
                FLEXManager.shared.showExplorer()
            }
            else
            {
                FLEXManager.shared.hideExplorer()
            }
        }
        self.devFunction.inApp = {
            InAppViewDebugger.present()
        }
        self.devFunction.flexBool = { show in
            if show
            {
                FLEXManager.shared.showExplorer()
            }
            else
            {
                FLEXManager.shared.hideExplorer()
            }
        }
#endif

        return true
    }
    
    @objc class func appDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func saveDataToCloud()
    {
        if let chatFavourite:String = UserDefaults.standard.value(forKey: uSaveChat) as? String
        {
            self.appConfig.chatFavourtie = chatFavourite
        }
                
        if let language:String = UserDefaults.standard.value(forKey: uLanguageKey) as? String
        {
            self.appConfig.language = language
        }
        
        if let drawSize:Data = UserDefaults.standard.value(forKey: uAiDrawSize) as? Data
        {
            self.appConfig.aiDrawSize = (try? CGSize.from(archivedData: drawSize))!
        }
        
        if let aiSmart:Double = UserDefaults.standard.value(forKey: uAiSmart) as? Double
        {
            self.appConfig.aiSmart = aiSmart
        }
        
        if let apiToken:String = UserDefaults.standard.value(forKey: uTokenKey) as? String
        {
            self.appConfig.apiToken = apiToken
        }
        
        if let aiModelType:String = UserDefaults.standard.value(forKey: uAiModelType) as? String
        {
            self.appConfig.aiModelType = aiModelType
        }
        
        if let waveColor:String = UserDefaults.standard.value(forKey: uWaveColor) as? String
        {
            self.appConfig.waveColor = UIColor(hexString: waveColor)!
        }
        
        if let botTextColor:String = UserDefaults.standard.value(forKey: uBotTextColor) as? String
        {
            self.appConfig.botTextColor = UIColor(hexString: botTextColor)!
        }
        
        if let userTextColor:String = UserDefaults.standard.value(forKey: uUserTextColor) as? String
        {
            self.appConfig.userTextColor = UIColor(hexString: userTextColor)!
        }
        
        if let botBubbleColor:String = UserDefaults.standard.value(forKey: uBotBubbleColor) as? String
        {
            self.appConfig.botBubbleColor = UIColor(hexString: botBubbleColor)!
        }
        
        if let userBubbleColor:String = UserDefaults.standard.value(forKey: uUserBubbleColor) as? String
        {
            self.appConfig.userBubbleColor = UIColor(hexString: userBubbleColor)!
        }
        
        if let userIcon:Data = UserDefaults.standard.value(forKey: uUserIcon) as? Data
        {
            self.appConfig.userIcon = userIcon
        }
        
        self.appConfig.firstUseiCloud = false
    }
    
    @objc func keyValueStoreDidChange(_ notification: Notification) {
        let userInfo = notification.userInfo
        if let keys = userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
            for key in keys {
                PTNSLogConsole(key)
                PTGCDManager.gcdMain {
                    switch key {
                    case uCheckSentence:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.checkSentence = chosenValue as! Bool
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.checkSentence = value as! Bool
                        }
                    case uGetImageCount:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.getImageCount = chosenValue as! Int
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.getImageCount = value as! Int
                        }
                    case uSegChatHistory:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.segChatHistory = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.segChatHistory = value as! String
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshCurrentTagData), object: nil)
                    case uUserIconURL:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.userIconURL = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.userIconURL = value as! String
                        }
                        self.query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
                        self.query.predicate = NSPredicate(format: "%K == %@", argumentArray: [NSMetadataItemFSNameKey, "userIcon.png"])
                        self.query.start()
                    case uUserIcon:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.userIcon = chosenValue as! Data
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.userIcon = value as! Data
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
                    case uUserBubbleColor:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.userBubbleColor = UIColor(hexString: chosenValue as! String)!
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.userBubbleColor = UIColor(hexString: value as! String)!
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
                    case uBotBubbleColor:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.botBubbleColor = UIColor(hexString: chosenValue as! String)!
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.botBubbleColor = UIColor(hexString: value as! String)!
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
                    case uUserTextColor:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.userTextColor = UIColor(hexString: chosenValue as! String)!
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.userTextColor = UIColor(hexString: value as! String)!
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
                    case uBotTextColor:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.botTextColor = UIColor(hexString: chosenValue as! String)!
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.botTextColor = UIColor(hexString: value as! String)!
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
                    case uWaveColor:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.waveColor = UIColor(hexString: chosenValue as! String)!
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.waveColor = UIColor(hexString: value as! String)!
                        }
                    case uAiModelType:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.aiModelType = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.aiModelType = value as! String
                        }
                    case uTokenKey:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.apiToken = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.apiToken = value as! String
                        }
                    case uAiSmart:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.aiSmart = chosenValue as! Double
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.aiSmart = value as! Double
                        }
                    case uAiDrawSize:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.aiDrawSize = (try? CGSize.from(archivedData: chosenValue as! Data))!
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.aiDrawSize = (try? CGSize.from(archivedData: value as! Data))!
                        }
                    case uLanguageKey:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.language = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.language = value as! String
                        }
                    case uSaveChat:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.chatFavourtie = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.chatFavourtie = value as! String
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshControllerAndLoadNewData), object: nil)
                    default:
                        break
                    }
                }
            }
        }
    }
}


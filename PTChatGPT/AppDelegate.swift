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
import HyperionCore
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
        FileManager.pt.createFolder(folderPath: userChatMessageFilePath)

        if let buildVersion = UserDefaults.standard.value(forKey: uAppBuildVersion) {
            let currentBuild = kAppBuildVersion!
            let didUpdate = (buildVersion as! String) != currentBuild
            
            if didUpdate {
                let dataString = self.appConfig.segChatHistory
                let chatString = self.appConfig.chatFavourtie

                if !dataString.stringIsEmpty() {
                    
                    var arr = [PTSegHistoryModel]()
                    let dataArr = dataString.components(separatedBy: kSeparatorSeg)
                    dataArr.enumerated().forEach { index,value in
                        let model = PTSegHistoryModel.deserialize(from: value)
                        arr.append(model!)
                    }
                    if arr.count > 1 || arr.first!.historyModel.count > 0 {
                        self.appConfig.setChatData = arr.kj.JSONObjectArray()
                    }
                    
                    self.appConfig.segChatHistory = ""
                }
                
                if !chatString.stringIsEmpty() {
                    var arrF = [PTFavouriteModel]()
                    let dataStringF = self.appConfig.chatFavourtie
                    let dataArrF = dataStringF.components(separatedBy: kSeparator)
                    if dataArrF.count > 0 {
                        dataArrF.enumerated().forEach { index,value in
                            if let model = PTFavouriteModel.deserialize(from: value) {
                                arrF.append(model)
                            }
                        }
                        self.appConfig.favouriteChat = arrF.kj.JSONObjectArray()
                    }
                    self.appConfig.chatFavourtie = ""
                }
                UserDefaults.standard.set(kAppBuildVersion, forKey: uAppBuildVersion)
            }
        } else {
            UserDefaults.standard.set(kAppBuildVersion, forKey: uAppBuildVersion)
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

        PTDarkModeOption.defaultDark()
        PTAppBaseConfig.share.decorationBackgroundColor = .gobalCellBackgroundColor
        StatusBarManager.shared.isHidden = false
        StatusBarManager.shared.style = PTDarkModeOption.isLight ? .darkContent : .lightContent
        
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
                
        #if DEBUG
        let filePath = NSTemporaryDirectory().appending("/demo.order")
        YCSymbolTracker.exportSymbols(filePath: filePath)
        #endif
                          
        PTNSLogConsole("\(self.appConfig.apiToken)")
        
        
        var viewC:UIViewController!
        if self.appConfig.apiToken.stringIsEmpty() {
            viewC = PTSettingViewController()
        } else {
            PTNSLogConsole(self.appConfig.tagDataArr())
            if Gobal_device_info.isPad {
                viewC = PTSplitViewController()
            } else {
                viewC = PTChatViewController(historyModel: PTSegHistoryModel())
            }
        }
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        if Gobal_device_info.isPad {
            self.window?.rootViewController = viewC
        } else {
            let nav = PTNavController(rootViewController: viewC)
            self.window?.rootViewController = nav
        }
        self.window?.makeKeyAndVisible()
        
        var fontSize:CGFloat = 16
        var skipFont:CGFloat = 16
        if Gobal_device_info.isPad {
            fontSize = 20
            skipFont = 30
        }
        
        PTLaunchAdMonitor.showAt(path: ["https://avatars.githubusercontent.com/u/1111976?v=4"], onView: self.window!, timeInterval: 2, param: ["URLS":myGithubUrl], year: "2023", skipFont: .appfont(size: skipFont), comName: "Crazypoo", comNameFont: .appfont(size: fontSize)) {
        }
        
#if DEBUG
        self.devFunction.createLabBtn()
        self.devFunction.goToAppDevVC = {
            let vc = PTDebugViewController()
            let nav = UINavigationController(rootViewController: vc)
            PTUtils.getCurrentVC().present(nav, animated: true)
        }
        self.devFunction.flex = {
            if FLEXManager.shared.isHidden {
                FLEXManager.shared.showExplorer()
            } else {
                FLEXManager.shared.hideExplorer()
            }
        }
        self.devFunction.inApp = {
            InAppViewDebugger.present()
        }
        self.devFunction.flexBool = { show in
            if show {
                FLEXManager.shared.showExplorer()
            } else {
                FLEXManager.shared.hideExplorer()
            }
        }
        self.devFunction.HyperioniOS = {
            HyperionManager.sharedInstance().attach(to: self.window)
            HyperionManager.sharedInstance().togglePluginDrawer()
        }
#endif        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlStr = url.absoluteString
        if urlStr.hasPrefix("chatzola://") {
            let newUrl = URL.init(string: urlStr.replacingOccurrences(of: "chatzola://", with: "http://127.0.0.1:9090?"))!
            let tagName = newUrl.queryValue(for: "chatTag")
            let chatText = newUrl.queryValue(for: "chatText")
            var selectedTagName = ""
            if (tagName ?? "").stringIsEmpty() || tagName == "Base" {
                selectedTagName = "Base"
            } else {
                selectedTagName = tagName!
            }
            
            if !(chatText ?? "").stringIsEmpty() {
                let datas = AppDelegate.appDelegate()!.appConfig.tagDataArr()
                for (index,value) in datas.enumerated() {
                    if value!.keyName == selectedTagName {
                        let data = datas[index]
                        let currentVC = PTUtils.getCurrentVC()
                        if currentVC is PTChatViewController {
                            let newCurrent = (currentVC as! PTChatViewController)
                            newCurrent.historyModel = data
                            PTGCDManager.gcdAfter(time: 0.35) {
                                newCurrent.insertMessages([chatText!])
                            }
                        } else {
                            if currentVC is PTColorSettingViewController {
                                currentVC.dismiss(animated: true) {
                                    let setting = (PTUtils.getCurrentVC() as! PTSettingListViewController)
                                    setting.navigationController?.popToRootViewController(animated: true)
                                    PTGCDManager.gcdAfter(time: 0.35) {
                                        let chat = (PTUtils.getCurrentVC() as! PTChatViewController)
                                        PTGCDManager.gcdAfter(time: 0.35) {
                                            chat.historyModel = data
                                            chat.messageInputBar.isHidden = false
                                            chat.messageInputBar.alpha = 1
                                            PTGCDManager.gcdAfter(time: 0.35) {
                                                chat.insertMessages([chatText!])
                                            }
                                        }
                                    }
                                }
                            } else {
                                let newCurrent = (PTUtils.getCurrentVC() as! PTSettingListViewController)
                                newCurrent.navigationController?.popViewController(animated: true) {
                                    PTGCDManager.gcdAfter(time: 0.35) {
                                        let chat = (PTUtils.getCurrentVC() as! PTChatViewController)
                                        PTGCDManager.gcdAfter(time: 0.35) {
                                            chat.historyModel = data
                                            chat.messageInputBar.isHidden = false
                                            chat.messageInputBar.alpha = 1
                                            PTGCDManager.gcdAfter(time: 0.35) {
                                                chat.insertMessages([chatText!])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
            return true
        }
        return false
    }
    
    @objc class func appDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
        
    @objc func keyValueStoreDidChange(_ notification: Notification) {
        let userInfo = notification.userInfo
        if let keys = userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
            for key in keys {
                PTNSLogConsole(key)
                PTGCDManager.gcdMain {
                    switch key {
                    case uUseCustomDomain:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.useCustomDomain = chosenValue as! Bool
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.useCustomDomain = value as! Bool
                        }
                    case uCustomDomain:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.customDomain = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.customDomain = value as! String
                        }
                    case uUserName:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.userName = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.userName = value as! String
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshController), object: nil)
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
                    case uSegChatHistorySaved:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.segChatHistorySaved = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.segChatHistorySaved = value as! String
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
                    case uSaveChatSaved:
                        if let conflictingValues = self.cloudStore.array(forKey: key) {
                            let chosenValue = conflictingValues.first
                            self.appConfig.chatFavourtieSaved = chosenValue as! String
                        } else {
                            let value = AppDelegate.appDelegate()!.cloudStore.object(forKey: key)
                            self.appConfig.chatFavourtieSaved = value as! String
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


//
//  AppDelegate.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import PooTools
#if DEBUG
#if canImport(FLEX)
import FLEX
#endif
#if canImport(InAppViewDebugger)
import InAppViewDebugger
#endif
#endif
//import YCSymbolTracker

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var devFunction:PTDevFunction = PTDevFunction()
    
    let appConfig = PTAppConfig.share
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
//        let filePath = NSTemporaryDirectory().appending("/demo.order")
//        YCSymbolTracker.exportSymbols(filePath: filePath)
        
        
        
        let token:String = UserDefaults.standard.value(forKey: uTokenKey) == nil ? "" : UserDefaults.standard.value(forKey: uTokenKey) as! String
        let language:OSSVoiceEnum = UserDefaults.standard.value(forKey: uLanguageKey) == nil ? .ChineseSimplified : UserDefaults.standard.value(forKey: uLanguageKey) as! OSSVoiceEnum
        
        PTLocalConsoleFunction.share.pNSLog("\(token)")
        var viewC:UIViewController!
        if token.stringIsEmpty()
        {
            viewC = PTSettingViewController()
        }
        else
        {
            viewC = PTChatViewController(token: token,language: language)
        }
        let nav = UINavigationController(rootViewController: viewC)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        self.devFunction.createLabBtn()
        self.devFunction.goToAppDevVC = {
            let vc = PTDebugViewController()
            let nav = UINavigationController(rootViewController: vc)
            PTUtils.getCurrentVC().present(nav, animated: true)
        }
#if DEBUG
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
        UIApplication.shared.delegate as? AppDelegate
    }
}


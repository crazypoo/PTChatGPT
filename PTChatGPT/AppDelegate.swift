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
                
        PTDrakModeOption.defaultDark()
//        let filePath = NSTemporaryDirectory().appending("/demo.order")
//        YCSymbolTracker.exportSymbols(filePath: filePath)
                        
        PTLocalConsoleFunction.share.pNSLog("\(self.appConfig.apiToken)")
        var viewC:UIViewController!
        if self.appConfig.apiToken.stringIsEmpty()
        {
            viewC = PTSettingViewController()
        }
        else
        {
            viewC = PTChatViewController(token: self.appConfig.apiToken,language: OSSVoiceEnum(rawValue: self.appConfig.language)!)
        }
        let nav = PTNavController(rootViewController: viewC)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        PTLaunchAdMonitor.showAt(path: ["https://avatars.githubusercontent.com/u/1111976?v=4"], onView: self.window!, timeInterval: 2, param: ["URLS":"https://github.com/crazypoo"], year: "2023", skipFont: .appfont(size: 10), comName: "Crazypoo", comNameFont: .appfont(size: 10)) {
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
        UIApplication.shared.delegate as? AppDelegate
    }
}


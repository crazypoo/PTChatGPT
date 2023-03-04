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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        let token:String = UserDefaults.standard.value(forKey: uTokenKey) == nil ? "" : UserDefaults.standard.value(forKey: uTokenKey) as! String

        PTLocalConsoleFunction.share.pNSLog("\(token)")
        var viewC:UIViewController!
        if token.stringIsEmpty()
        {
            viewC = PTSettingViewController()
        }
        else
        {
            viewC = PTChatViewController(token: token)
        }
        let nav = UINavigationController(rootViewController: viewC)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        
        let devFunction = PTDevFunction()
        devFunction.createLabBtn()
        devFunction.goToAppDevVC = {
            let vc = PTDebugViewController()
            let nav = UINavigationController(rootViewController: vc)
            PTUtils.getCurrentVC().present(nav, animated: true)
        }
#if DEBUG
        devFunction.flex = {
            if FLEXManager.shared.isHidden
            {
                FLEXManager.shared.showExplorer()
            }
            else
            {
                FLEXManager.shared.hideExplorer()
            }
        }
        devFunction.inApp = {
            InAppViewDebugger.present()
        }
        devFunction.flexBool = { show in
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


//
//  AppDelegate.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import PooTools

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        let token:String = UserDefaults.standard.value(forKey: "UserToken") == nil ? "" : UserDefaults.standard.value(forKey: "UserToken") as! String

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

        return true
    }
}


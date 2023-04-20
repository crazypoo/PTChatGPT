//
//  PTSplitViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 31/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTSplitViewController: UISplitViewController {

    lazy var currentChatViewController:PTChatViewController = {
        if let splitViewController = self.splitViewController,
            let detailViewController = splitViewController.viewControllers.last as? PTNavController {
            // 在这里使用detailViewController
            let chat = detailViewController.viewControllers.first as! PTChatViewController
            return chat
        } else if let detailViewController = self.navigationController?.viewControllers.last as? PTNavController {
            // 在这里使用detailViewController
            let chat = detailViewController.viewControllers.first as! PTChatViewController
            return chat
        } else {
            return PTChatViewController(historyModel: PTSegHistoryModel())
        }
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let chatVc = PTChatViewController(historyModel: PTSegHistoryModel())
        let nav = PTNavController(rootViewController: chatVc)
        self.showDetailViewController(nav, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .gobalBackgroundColor
        
        self.setUpSpliteViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.adHide(nofiti:)), name: NSNotification.Name(rawValue: PLaunchAdSkipNotification), object: nil)
    }
    
    func setUpSpliteViewController() {
        let master = PTChatMasterControl()
        
        self.viewControllers = [master]
        self.preferredDisplayMode = .oneBesideSecondary
        self.maximumPrimaryColumnWidth = iPadSplitMainControl
    }
    
    @objc func adHide(nofiti:Notification) {
        if AppDelegate.appDelegate()!.appConfig.firstUseApp {
            AppDelegate.appDelegate()!.appConfig.firstUseApp = false
            if AppDelegate.appDelegate()!.appConfig.apiToken.stringIsEmpty() {
                let keySetting = PTSettingViewController()
                keySetting.skipBlock = {
                    self.currentChatViewController.showKeyboard()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: nSetKey), object: nil)
                }
                PTFloatingPanelFuction.floatPanel_VC(vc:keySetting,panGesDelegate:self,currentViewController:self) {
                    self.currentChatViewController.showKeyboard()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: nSetKey), object: nil)
                }
            }
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(nPadReloadKey), object: nil)
        }
    }
}

extension PTSplitViewController:UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

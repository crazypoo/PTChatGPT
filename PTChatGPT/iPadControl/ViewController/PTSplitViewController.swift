//
//  PTSplitViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 31/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit

class PTSplitViewController: UISplitViewController {

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

    }
    
    func setUpSpliteViewController() {
        let master = PTChatMasterControl()
        
        self.viewControllers = [master]
        self.preferredDisplayMode = .oneBesideSecondary
        self.maximumPrimaryColumnWidth = iPadSplitMainControl
    }
}

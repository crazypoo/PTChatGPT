//
//  PTSplitViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 31/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit

class PTSplitViewController: UISplitViewController {

    var detailController = NSMutableArray()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showDetailViewController((self.detailController.firstObject as! PTNavController), sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .gobalBackgroundColor
        
        self.setUpSpliteViewController()
    }
    
    func setUpSpliteViewController() {
        let master = PTChatMasterControl()
        
        let chatVc = PTChatViewController(historyModel: PTSegHistoryModel())
        let nav = PTNavController(rootViewController: chatVc)
        self.detailController.add(nav)
        self.viewControllers = [master]
        self.preferredDisplayMode = .oneBesideSecondary
        self.maximumPrimaryColumnWidth = iPadSplitMainControl
    }
}

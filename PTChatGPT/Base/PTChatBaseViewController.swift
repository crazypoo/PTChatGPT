//
//  PTChatBaseViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTChatBaseViewController: PTBaseViewController {
    
    var user:PTChatUser = PTChatUser(senderId: "0", displayName: "0")

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let type:VCStatusBarChangeStatusType = PTDrakModeOption.isLight ? .Light : .Dark
        self.changeStatusBar(type: type)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let type:VCStatusBarChangeStatusType = PTDrakModeOption.isLight ? .Light : .Dark
        self.changeStatusBar(type: type)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.zx_navTitleFont = .appfont(size: 24,bold:true)
        self.zx_navLineView?.isHidden = true
        self.zx_navTitleColor = .gobalTextColor
        self.view.backgroundColor = .gobalBackgroundColor
        self.zx_navBar?.backgroundColor = .gobalBackgroundColor
    }
}

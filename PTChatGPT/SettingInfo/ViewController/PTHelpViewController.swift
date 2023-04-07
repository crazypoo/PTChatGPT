//
//  PTHelpViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 26/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTHelpViewController: PTChatBaseViewController {

    lazy var infoLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.zx_navTitle = SettingHelp
        // Do any additional setup after loading the view.
        self.view.addSubviews([self.infoLabel])
        self.infoLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        
        let att = NSMutableAttributedString.sj.makeText { make in
            make.append("URL SCHEME").alignment(.left).font(.appfont(size: 24,bold: true)).textColor(.gobalTextColor).lineSpacing(15)
            make.append("\n\(PTLanguage.share.text(forKey: "help_Base")):").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(5)
            make.append("\nchatzola://chatTag=Base&chatText=Hola").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(5)
            make.append("\n\(PTLanguage.share.text(forKey: "help_And"))").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(5)
            make.append("\nchatzola://chatText=Hola").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(5)
            
            make.append("\n").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(15)
            make.append("\n\(PTLanguage.share.text(forKey: "help_Other")):").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(5)
            make.append("\nchatzola://chatTag=XXXXXXXXXXXXXXXXXXXXX&chatText=Hola").alignment(.left).font(.appfont(size: 20,bold: true)).textColor(.gobalTextColor).lineSpacing(5)
        }
        self.infoLabel.attributedText = att
    }
}

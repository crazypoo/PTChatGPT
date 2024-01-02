//
//  PTHelpViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 26/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import AttributedString

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
        
        let att:ASAttributedString = """
        \(wrap: .embedding("""
        \("URL SCHEME",.paragraph(.alignment(.left),.lineSpacing(15)),.foreground(.gobalTextColor),.font(.appfont(size: 24,bold: true)))
        \("\(PTAppConfig.languageFunc(text: "help_Base")):",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 20,bold: true)))
        \("chatzola://chatTag=Base&chatText=Hola",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 20,bold: true)))
        \("\(PTAppConfig.languageFunc(text: "help_And"))",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 20,bold: true)))
        \("chatzola://chatText=Hola",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 20,bold: true)))
        
        \("\(PTAppConfig.languageFunc(text: "help_Other")):",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 20,bold: true)))
        \("chatzola://chatTag=XXXXXXXXXXXXXXXXXXXXX&chatText=Hola",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 20,bold: true)))
        """),.paragraph(.alignment(.left)))
        """        
        self.infoLabel.attributed.text = att
    }
}

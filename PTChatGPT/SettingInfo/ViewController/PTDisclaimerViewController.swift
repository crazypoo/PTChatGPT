//
//  PTDisclaimerViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 10/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTDisclaimerViewController: PTChatBaseViewController {

    let firstTitle = PTLanguage.share.text(forKey: "disclaimer_App")
    let secondTitle = PTLanguage.share.text(forKey: "disclaimer_External")

    lazy var labelContent:UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    lazy var infoLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = "Disclaimer"
        
        self.view.addSubview(self.labelContent)
        self.labelContent.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        
        self.labelContent.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { make in
            make.width.equalTo(CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2)
            make.centerX.equalToSuperview()
            make.top.equalTo(0)
        }
        
        self.infoLabel.attributedText = NSMutableAttributedString.sj.makeText({ make in
            make.append(firstTitle).alignment(.center).font(.appfont(size: 18,bold: true)).textColor(.gobalTextColor)
            make.append("\n" + AppDisclaimer).alignment(.left).font(.appfont(size: 16)).textColor(.gobalTextColor)
            make.append("\n" + secondTitle).alignment(.center).font(.appfont(size: 18,bold: true)).textColor(.gobalTextColor)
            make.append("\n" + ExternalLinksDisclaimer).alignment(.left).font(.appfont(size: 16)).textColor(.gobalTextColor)
        })
        
        let firstTitleHeight = UIView.sizeFor(string: firstTitle, font: .appfont(size: 18,bold: true), height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2).height
        let firstInfoHeight = UIView.sizeFor(string: AppDisclaimer, font: .appfont(size: 16),lineSpacing: 3, height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2).height
        
        let secondTitleHeight = UIView.sizeFor(string: secondTitle, font: .appfont(size: 18,bold: true), height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2).height
        let secondInfoHeight = UIView.sizeFor(string: ExternalLinksDisclaimer, font: .appfont(size: 16),lineSpacing: 3, height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2).height

        self.labelContent.contentSize = CGSize(width: CGFloat.kSCREEN_WIDTH, height: firstTitleHeight + firstInfoHeight + secondTitleHeight + secondInfoHeight)
    }
}

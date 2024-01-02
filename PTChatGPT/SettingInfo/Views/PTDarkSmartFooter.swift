//
//  PTDarkSmartFooter.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 20/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTDarkSmartFooter: PTBaseCollectionReusableView {
    static let ID = "PTDarkSmartFooter"
    
    static let footerDescFont:UIFont = .appfont(size: 14)
    
    static let footerTotalHeight = 10 + UIView.sizeFor(string: PTAppConfig.languageFunc(text: "theme_SmartInfo"), font: PTDarkSmartFooter.footerDescFont, height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2).height + 10 + 44 * 2
    
    lazy var footerContent:UIView = {
        let view = UIView()
        view.backgroundColor = .gobalCellBackgroundColor
        return view
    }()
    
    lazy var descLabel:UILabel = {
        let view = UILabel()
        view.text = PTAppConfig.languageFunc(text: "theme_SmartInfo")
        view.font = PTDarkSmartFooter.footerDescFont
        view.numberOfLines = 0
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        return view
    }()
    
    lazy var themeName:UILabel = {
        let view = UILabel()
        view.text = PTAppConfig.languageFunc(text: "theme_Night")
        view.font = .appfont(size: 16)
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        return view
    }()
    
    lazy var themeNight:UILabel = {
        let view = UILabel()
        view.text = PTAppConfig.languageFunc(text: "theme_Black")
        view.font = .appfont(size: 16)
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        return view
    }()

    lazy var themeTime:UILabel = {
        let view = UILabel()
        view.text = PTAppConfig.languageFunc(text: "theme_Time")
        view.font = .appfont(size: 16)
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        return view
    }()
    
    lazy var themeTimeButton:PTLayoutButton = {
        let view = PTLayoutButton()
        view.layoutStyle = .leftTitleRightImage
        view.midSpacing = 5
        view.setTitle(PTDarkModeOption.smartPeelingTimeIntervalValue, for: .normal)
        view.setImage(UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal), for: .normal)
        view.titleLabel?.font = .appfont(size: 16)
        view.setTitleColor(.gobalTextColor, for: .normal)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.footerContent)
        self.footerContent.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.top.bottom.equalToSuperview()
        }
        
        self.footerContent.addSubviews([self.descLabel,self.themeName,self.themeNight,self.themeTime,self.themeTimeButton])
        self.descLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
        }
        
        self.themeName.snp.makeConstraints { make in
            make.left.equalTo(self.descLabel)
            make.top.equalTo(self.descLabel.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        self.themeNight.snp.makeConstraints { make in
            make.right.equalTo(self.descLabel)
            make.top.bottom.equalTo(self.themeName)
        }
        self.themeTime.snp.makeConstraints { make in
            make.top.equalTo(self.themeName.snp.bottom)
            make.left.equalTo(self.descLabel)
            make.height.equalTo(self.themeName)
        }
        self.themeTimeButton.snp.makeConstraints { make in
            make.right.equalTo(self.descLabel)
            make.centerY.equalTo(self.themeTime)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

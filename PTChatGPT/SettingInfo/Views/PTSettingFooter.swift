//
//  PTSettingFooter.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 18/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTSettingFooter: PTBaseCollectionReusableView {
    static let ID = "PTSettingFooter"
    
    lazy var verionLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .lightGray
        view.text = kAppName! + " " + kAppVersion! + "(\(kAppBuildVersion!))"
        view.font = .appfont(size: 13)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        self.addSubview(self.verionLabel)
        self.verionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  PTSettingHeader.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import SnapKit
import SwifterSwift

class PTSettingHeader: PTBaseCollectionReusableView {
    static let ID = "PTSettingHeader"
    
    lazy var titleLabel : UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .appfont(size: 14)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

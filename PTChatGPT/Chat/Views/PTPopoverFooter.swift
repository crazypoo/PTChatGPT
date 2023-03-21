//
//  PTPopoverFooter.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 22/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTPopoverFooter: PTBaseCollectionReusableView {
    static let ID = "PTPopoverFooter"
    
    lazy var deleteButton:UIButton = {
        let view = UIButton(type: .custom)
        view.setImage("🗑️".emojiToImage(emojiFont: .appfont(size: 24)), for: .normal)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.left.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

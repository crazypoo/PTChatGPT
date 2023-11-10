//
//  PTSuggesstionCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 28/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import AttributedString

class PTSuggesstionCell: PTBaseNormalCell {
    static let ID = "PTSuggesstionCell"
    
    static let titleFont:UIFont = .appfont(size: 18,bold: true)
    static let nameFont:UIFont = .appfont(size: 12)
    static let infoFont:UIFont = .appfont(size: 15)

    var cellModel:PTSampleModels? {
        didSet {
            
            let att:ASAttributedString = """
            \(wrap: .embedding("""
            \("\(self.cellModel!.keyName)",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.white),.font(PTSuggesstionCell.titleFont))
            \("\(self.cellModel!.who.stringIsEmpty() ? "@anonymous" : self.cellModel!.who)",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.white),.font(PTSuggesstionCell.nameFont))
            \("\(self.cellModel!.systemContent)",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.white),.font(PTSuggesstionCell.infoFont))
            """),.paragraph(.alignment(.left)))
            """
            self.infoLaebl.attributed.text = att

            self.addButton.isHidden = self.cellModel!.imported
        }
    }
    
    lazy var infoLaebl : UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    lazy var addButton:PTLayoutButton = {
        let view = PTLayoutButton()
        view.layoutStyle = .leftImageRightTitle
        view.normalTitleFont = .appfont(size: 13)
        view.midSpacing = 0
        view.setTitle(PTLanguage.share.text(forKey: "bot_Suggesstion_import"), for: .normal)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubviews([self.addButton,self.infoLaebl])
        
        self.addButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(34)
            make.width.equalTo(self.addButton.sizeFor(height: 34).width + 15)
        }
        
        self.infoLaebl.snp.makeConstraints { make in
            make.left.equalTo(self.addButton)
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalTo(self.addButton.snp.top).offset(-10)
        }
        
        PTGCDManager.gcdMain {
            self.contentView.viewCorner(radius: 5)
            self.addButton.viewCorner(radius: 3,borderWidth: 1,borderColor: .white)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

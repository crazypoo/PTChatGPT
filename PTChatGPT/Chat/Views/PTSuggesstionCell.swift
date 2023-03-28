//
//  PTSuggesstionCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 28/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTSuggesstionCell: PTBaseNormalCell {
    static let ID = "PTSuggesstionCell"
    
    static let titleFont:UIFont = .appfont(size: 18,bold: true)
    static let nameFont:UIFont = .appfont(size: 12)
    static let infoFont:UIFont = .appfont(size: 15)

    var cellModel:PTSampleModels? {
        didSet {
            let att = NSMutableAttributedString.sj.makeText { make in
                make.append(self.cellModel!.keyName).lineSpacing(5).font(PTSuggesstionCell.titleFont).textColor(.white).alignment(.left)
                make.append("\n\(self.cellModel!.who)").lineSpacing(5).font(PTSuggesstionCell.nameFont).textColor(.white).alignment(.left)
                make.append("\n\(self.cellModel!.systemContent)").lineSpacing(5).font(PTSuggesstionCell.infoFont).textColor(.white).alignment(.left)
            }
            self.infoLaebl.attributedText = att

            self.addButton.isHidden = self.cellModel!.imported
        }
    }
    
    lazy var infoLaebl : UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    lazy var addButton:BKLayoutButton = {
        let view = BKLayoutButton()
        view.layoutStyle = .leftImageRightTitle
        view.titleLabel?.font = .appfont(size: 13)
        view.setMidSpacing(0)
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
            make.width.equalTo(self.addButton.sizeFor(size: CGSize(width: CGFloat(MAXFLOAT), height: 34)).width + 15)
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

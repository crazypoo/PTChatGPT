//
//  PTPopoverCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 19/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTPopoverCell: PTBaseSwipeCell {
    static let ID = "PTPopoverCell"
    
    var cellModel:PTSegHistoryModel? {
        didSet {
            if !self.cellModel!.systemContent.stringIsEmpty() {
                let att = NSMutableAttributedString.sj.makeText { make in
                    make.append(self.cellModel!.keyName).font(.appfont(size: 14)).textColor(.gobalTextColor).alignment(.left).lineSpacing(5)
                    make.append("\n\(self.cellModel!.systemContent)").font(.appfont(size: 12)).textColor(.lightGray).alignment(.left)
                }
                self.nameLabel.attributedText = att
            } else {
                self.nameLabel.text = self.cellModel!.keyName
            }
        }
    }
    
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                self.selectedView.isHidden = false
            } else {
                self.selectedView.isHidden = true
            }
        }
    }
    
    lazy var nameLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .appfont(size: 14)
        view.textColor = .gobalTextColor
        view.numberOfLines = 0
        return view
    }()
    
    lazy var bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var selectedView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.automatic)
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubviews([self.nameLabel,self.bottomLine,self.selectedView])
        self.selectedView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.selectedView.snp.left).offset(-10)
        }
        self.bottomLine.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

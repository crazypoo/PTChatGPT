//
//  PTAISmartCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 10/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTAISmartCell: PTBaseNormalCell {
    static let ID = "PTAISmartCell"
    
    lazy var lineView = self.drawLine()
    
    lazy var nameTitle:UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        return view
    }()
        
    lazy var aiSlider:PTSlider = {
        
        var smartValue = Float(1 - AppDelegate.appDelegate()!.appConfig.aiSmart)
        if smartValue <= 0 {
            smartValue = 1
        }
        let slider = PTSlider(showTitle: true, titleIsValue: false)
        slider.maximumValue = 1
        slider.minimumValue = 0.1
        slider.value = smartValue
        slider.tintColor = .orange
        slider.titleColor = .orange
        slider.backgroundColor = .clear
        return slider
    }()
    
    var cellModel:PTFusionCellModel? {
        didSet {
            self.nameTitle.text = self.cellModel!.name
            self.nameTitle.textColor = self.cellModel!.nameColor
            self.nameTitle.font = self.cellModel!.cellFont
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var titleHeight:CGFloat = 0
        if Gobal_device_info.isPad {
            titleHeight = 34
        } else {
            titleHeight = CGFloat.ScaleW(w: 34)
        }
        
        self.contentView.addSubviews([self.nameTitle,self.lineView,self.aiSlider])
        self.nameTitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.height.equalTo(titleHeight)
        }
        
        self.lineView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(self.cellModel?.rightSpace ?? 10)
            make.height.equalTo(1)
            make.top.equalToSuperview()
            make.left.equalTo(self.nameTitle)
        }
        
        self.aiSlider.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.top.equalTo(self.nameTitle.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawLine() -> UIView {
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.init(hexString: "#E8E8E8")
        return lineView
    }
}

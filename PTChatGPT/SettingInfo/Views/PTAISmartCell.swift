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
    
    lazy var aiSlider:UISlider = {
        let slider = UISlider()
        slider.maximumValue = 1
        slider.minimumValue = 0.1
        slider.value = Float(1 - AppDelegate.appDelegate()!.appConfig.aiSmart)
        return slider
    }()
    
    var cellModel:PTFusionCellModel?
    {
        didSet{
            self.nameTitle.text = self.cellModel!.name
            self.nameTitle.textColor = self.cellModel!.nameColor
            self.nameTitle.font = self.cellModel!.cellFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubviews([self.nameTitle,self.lineView,self.aiSlider])
        self.nameTitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.height.equalTo(CGFloat.ScaleW(w: 34))
        }
        
        self.lineView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(self.cellModel?.rightSpace ?? 10)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(self.nameTitle)
        }
        
        self.aiSlider.snp.makeConstraints { make in
            make.left.right.equalTo(self.nameTitle)
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

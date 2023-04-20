//
//  PTCostCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 7/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import AttributedString

class PTCostCell: PTBaseNormalCell {
    static let ID = "PTCostCell"
    
    var cellModel:PTCostMainModel? {
        didSet {
            var textFont:UIFont
            if Gobal_device_info.isPad {
                textFont = .appfont(size: 16)
            } else {
                textFont = .appfont(size: 14)
            }

            var questionType = ""
            var answer = ""
            switch self.cellModel!.historyType {
            case 0:
                let aiType:OpenAIModelType = AppDelegate.appDelegate()!.appConfig.getAIMpdelType(typeString: self.cellModel!.modelName)
                let cost = String(format: "%f", AppDelegate.appDelegate()!.appConfig.tokenCostCalculation(type: aiType, usageModel: self.cellModel!.tokenUsage))
                questionType = "📝"
                answer = "🤖:\(self.cellModel!.modelName)\n✏️:\(self.cellModel!.tokenUsage.prompt_tokens)\n🖊️:\(self.cellModel!.tokenUsage.completion_tokens)\n🟰:\(self.cellModel!.tokenUsage.total_tokens)\n💸:\(cost)"
            case 1:
                let cost = String(format: "%f", AppDelegate.appDelegate()!.appConfig.tokenCostImageCalculation(imageCount: self.cellModel!.imageURL.count))
                questionType = "🎨"
                answer = "🏞️:\(self.cellModel!.imageURL.count)\n📏:\(self.cellModel!.imageSize)\n💸:\(cost)"
            default:break
            }

            let att:ASAttributedString = """
            \(wrap: .embedding("""
            \("⏰\(self.cellModel!.costDate)",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(textFont))
            \("\(questionType)",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 14)))
            \("\(answer)",.paragraph(.alignment(.left),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 14)))
            """),.paragraph(.alignment(.left)))
            """
            self.timeLabelAndQ.attributed.text = att
        }
    }
    
    lazy var timeLabelAndQ:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    lazy var lineView:UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubviews([self.timeLabelAndQ,self.lineView])
        self.timeLabelAndQ.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(5)
        }
        
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalTo(self.timeLabelAndQ)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        self.lineView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

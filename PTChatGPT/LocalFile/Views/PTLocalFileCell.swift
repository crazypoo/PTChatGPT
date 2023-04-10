//
//  PTLocalFileCell.swift
//  ChangePhoneData
//
//  Created by 邓杰豪 on 14/3/23.
//  Copyright © 2023 Jax. All rights reserved.
//

import UIKit
import PooTools

class PTLocalFileCell: PTBaseNormalCell {
    static let ID = "PTLocalFileCell"
    
    var cellModel:PTLocalFileModel? {
        didSet {
            self.imageView.image = self.cellModel!.image
            self.nameLabel.text = self.cellModel!.fileName
        }
    }
    
    var cellAction:Bool = false {
        didSet {
            self.deleteButton.isHidden = !self.cellAction
            self.deleteButton.isUserInteractionEnabled = self.cellAction
        }
    }
    
    lazy var imageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()
    
    lazy var nameLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .appfont(size: 14)
        view.textColor = .black
        return view
    }()
        
    lazy var deleteButton:UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.automatic), for: .normal)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.viewCorner(radius: 5)
        
        self.contentView.addSubviews([self.imageView,self.nameLabel,self.deleteButton])
        self.imageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.imageView.snp.bottom)
        }
                
        self.deleteButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        self.contentView.viewCorner(radius:5,borderWidth:1,borderColor:.lightGray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

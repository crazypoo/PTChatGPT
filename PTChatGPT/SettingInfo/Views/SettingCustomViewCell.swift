//
//  SettingCustomViewCell.swift
//  PTNetworkTesting
//
//  Created by 邓杰豪 on 7/3/23.
//


import UIKit
import PooTools

class SettingCustomViewCell: UITableViewCell {

    /// 文本的展示
    var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .appfont(size: 16)
        label.textColor = .gobalTextColor
        label.textAlignment = .left
        return label
    }()
    
    /// 描述文本的展示
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .appfont(size: 15)
        label.textColor = .gobalTextColor
        // label.backgroundColor = .randomColor
        label.textAlignment = .right
        return label
    }()
    
    /// 有更新的红点
    var redView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.layer.cornerRadius = 3
        view.clipsToBounds = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // self.selectionStyle = .none
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(redView)
        self.contentView.addSubview(descriptionLabel)
        // self.contentView.addSubview(lineView)
        contentLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(15)
            make.width.equalTo(100)
        }
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.right.equalTo(-20)
            make.width.lessThanOrEqualTo(100)
        }
        redView.snp.makeConstraints { make in
            make.centerY.equalTo(descriptionLabel.snp.centerY)
            make.size.equalTo(CGSize(width: 6, height: 6))
            make.right.equalTo(descriptionLabel.snp.left).offset(-6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

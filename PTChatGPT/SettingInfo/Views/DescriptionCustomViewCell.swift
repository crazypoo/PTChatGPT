//
//  DescriptionCustomViewCell.swift
//  PTNetworkTesting
//
//  Created by 邓杰豪 on 7/3/23.
//


import UIKit
import PooTools

class DescriptionCustomViewCell: UITableViewCell {

    /// 文本的展示
    var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .appfont(size: 14)
        label.textColor = .gobalTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // self.selectionStyle = .none
        self.contentView.backgroundColor = .gobalBackgroundColor
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 15, bottom: 12, right: 15))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

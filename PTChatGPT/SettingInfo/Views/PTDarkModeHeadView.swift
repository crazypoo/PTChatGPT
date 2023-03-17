//
//  PTDarkModeHeadView.swift
//  PTNetworkTesting
//
//  Created by 邓杰豪 on 7/3/23.
//


import UIKit
import PooTools
import SwifterSwift

extension UIImage {
    /// 选中
    private(set) static var tradeValidperiodSelected = UIImage(named: "trade_validperiod_selected")
    /// 没有选中
    private(set) static var tradeValidperiod = UIImage(named: "trade_validperiod")
}

/// 暗黑模式
enum DarkMode {
    case light
    case dark
}

class PTDarkModeHeadView: UIView {
    private var currentMode: DarkMode?
    /// 模式选择
    var selectModeClosure: ((DarkMode) -> Void)?
    /// 顶部标题
    lazy var topLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: 100, height: 55))
        label.text = PTLanguage.share.text(forKey: "theme_MT")
        label.textAlignment = .left
        label.font = .appfont(size: 16)
        label.textColor = .gobalTextColor
        return label
    }()
    /// 浅色图片
    lazy var lightImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: CGFloat.kSCREEN_WIDTH / 2.0 - 18 - 80, y: 76, width: 80, height: 150))
        imageView.image = UIColor.white.createImageWithColor()
        return imageView
    }()
    /// 深色图片
    lazy var darkImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: CGFloat.kSCREEN_WIDTH / 2.0 + 18, y: 76, width: 80, height: 150))
        imageView.image = UIColor.gobalTextColor.createImageWithColor()
        return imageView
    }()
    
    /// 浅色选中图片
    lazy var lightSelectedImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 浅色选中的文字
    lazy var lightSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = PTLanguage.share.text(forKey: "theme_White")
        label.textAlignment = .left
        label.font = .appfont(size: 13)
        label.textColor = .gobalTextColor
        return label
    }()
    
    /// 深色选中图片
    lazy var darkSelectedImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 深色选中的文字
    lazy var darkSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = PTLanguage.share.text(forKey: "theme_Black")
        label.textAlignment = .left
        label.font = .appfont(size: 13)
        label.textColor = .gobalTextColor
        return label
    }()
    
    /// 浅色的按钮
    lazy var lightSelectedButton: UIButton = {
        let button = UIButton(frame: CGRect(x: CGFloat.kSCREEN_WIDTH / 2.0 - 18 - 80, y: 76, width: 80, height: 185))
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        button.tag = 100
        return button
    }()
    
    /// 深色的按钮
    lazy var darkSelectedButton: UIButton = {
        let button = UIButton(frame: CGRect(x: CGFloat.kSCREEN_WIDTH / 2.0 + 18, y: 76, width: 80, height: 185))
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        button.tag = 101
        return button
    }()
    
    init(frame: CGRect, currentMode: DarkMode) {
        super.init(frame: frame)
        self.currentMode = currentMode
        initUI()
        commonUI()
        updateTheme()
    }
    
    /// 创建控件
    private func initUI() {
        addSubviews([topLabel,lightImageView,darkImageView,lightSelectedImageView,lightSelectedLabel,darkSelectedImageView,darkSelectedLabel,lightSelectedButton,darkSelectedButton])
        
        lightSelectedImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.left.equalTo(self.lightImageView.snp.left).offset(6)
            make.top.equalTo(self.lightImageView.snp.bottom).offset(14)
        }
        
        lightSelectedLabel.snp.makeConstraints { make in
            make.width.equalTo(42)
            make.height.equalTo(19)
            make.top.equalTo(self.lightImageView.snp.bottom).offset(14)
            make.left.equalTo(self.lightSelectedImageView.snp.right).offset(10)
        }
        
        darkSelectedImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.left.equalTo(self.darkImageView.snp.left).offset(6)
            make.top.equalTo(self.darkImageView.snp.bottom).offset(14)
        }

        darkSelectedLabel.snp.makeConstraints { make in
            make.width.equalTo(42)
            make.height.equalTo(19)
            make.top.equalTo(self.lightImageView.snp.bottom).offset(14)
            make.left.equalTo(self.darkSelectedImageView.snp.right).offset(10)
        }
    }
    
    /// 添加控件和设置约束
    private func commonUI() {
        
    }
    
    /// 更新控件的颜色，字体，背景色等等
    private func updateTheme() {
        if currentMode == .light {
            lightSelectedImageView.image = UIImage.tradeValidperiodSelected
            darkSelectedImageView.image = UIImage.tradeValidperiod
        } else {
            lightSelectedImageView.image = UIImage.tradeValidperiod
            darkSelectedImageView.image = UIImage.tradeValidperiodSelected
        }
    }
    
    // MARK: 按钮的点击事件
    @objc func click(sender: UIButton) {
        if sender.tag == 100 {
            lightSelectedImageView.image = UIImage.tradeValidperiodSelected
            darkSelectedImageView.image = UIImage.tradeValidperiod
            selectModeClosure?(.light)
        } else {
            lightSelectedImageView.image = UIImage.tradeValidperiod
            darkSelectedImageView.image = UIImage.tradeValidperiodSelected
            selectModeClosure?(.dark)
        }
    }
    
    /// 更新选择
    func updateSelected() {
        if PTDrakModeOption.isLight {
            lightSelectedImageView.image = UIImage.tradeValidperiodSelected
            darkSelectedImageView.image = UIImage.tradeValidperiod
        } else {
            lightSelectedImageView.image = UIImage.tradeValidperiod
            darkSelectedImageView.image = UIImage.tradeValidperiodSelected
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if PTDrakModeOption.isFollowSystem, #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .light {
                lightSelectedImageView.image = UIImage.tradeValidperiodSelected
                darkSelectedImageView.image = UIImage.tradeValidperiod
            } else {
                lightSelectedImageView.image = UIImage.tradeValidperiod
                darkSelectedImageView.image = UIImage.tradeValidperiodSelected
            }
        }
    }
}

//
//  PTDarkModeSettingViewController.swift
//  PTNetworkTesting
//
//  Created by 邓杰豪 on 7/3/23.
//

import UIKit
import PooTools

class PTDarkModeSettingViewController: PTChatBaseViewController {

    /// 顶部的视图
    lazy var topHeadView: PTDarkModeHeadView = {
        let headView = PTDarkModeHeadView(frame: CGRect(x: 0, y: 0, width: CGFloat.kSCREEN_WIDTH, height: 285), currentMode: PTDrakModeOption.isLight ? .light : .dark)
        headView.selectModeClosure = {[weak self] (mode) in
            guard let weakSelf = self else { return }
            PTDrakModeOption.setDarkModeCustom(isLight: mode == .light ? true : false)
            // 更新选择
            weakSelf.topHeadView.updateSelected()
            weakSelf.tableView.reloadData()
        }
        return headView
    }()
    
    /// 黑色模式的时间
    private var darkTime: String = PTDrakModeOption.smartPeelingTimeIntervalValue
    
    lazy var dataArray: [String] = {
        var array: [String] = []
        if #available(iOS 13, *) {
            array = [PTLanguage.share.text(forKey: "theme_Smart"), PTLanguage.share.text(forKey: "theme_FollowSystem")]
        } else {
            array = [PTLanguage.share.text(forKey: "theme_Smart")]
        }
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PTLanguage.share.text(forKey: "theme_Title")
        self.view.backgroundColor = .gobalBackgroundColor
        initUI()
        commonUI()
        updateTheme()
        themeProvider.register(observer: self)
    }
    
    /// 创建控件
    private func initUI() {
        self.view.addSubview(tableView)
    }
    
    /// 添加控件和设置约束
    private func commonUI() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: CGFloat.kNavBarHeight_Total, left: 0, bottom: 0, right: 0))
        }
    }
    
    /// 更新控件的颜色，字体，背景色等等
    private func updateTheme() {
        apply()
    }
    
    lazy var tableView : UITableView = {
        
        let tableView = UITableView(frame: CGRect(x:0, y: CGFloat.kNavBarHeight_Total, width: CGFloat.kSCREEN_WIDTH, height: CGFloat.kSCREEN_HEIGHT - CGFloat.kNavBarHeight_Total), style:.grouped)
        if #available(iOS 11, *) {
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.kSCREEN_WIDTH, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.kSCREEN_WIDTH, height: 0.01))
        tableView.tableHeaderView = topHeadView
        tableView.register(cellWithClass: SettingCustomViewCell.self)
        tableView.register(cellWithClass: DescriptionCustomViewCell.self)
        return tableView
    }()
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PTDarkModeSettingViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = dataArray[section]
        if sectionName == PTLanguage.share.text(forKey: "theme_Smart") {
            return PTDrakModeOption.isSmartPeeling ? 3 : 0
        } else if sectionName == PTLanguage.share.text(forKey: "theme_FollowSystem") {
            return PTDrakModeOption.isFollowSystem ? 1 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withClass: DescriptionCustomViewCell.self, for: indexPath)
                cell.contentLabel.text = PTLanguage.share.text(forKey: "theme_SmartInfo")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withClass: SettingCustomViewCell.self, for: indexPath)
                cell.contentLabel.text = indexPath.row == 1 ? PTLanguage.share.text(forKey: "theme_Night") : PTLanguage.share.text(forKey: "theme_Time")
                cell.backgroundColor = .gobalBackgroundColor
                cell.contentLabel.font = .appfont(size: 15)
                cell.descriptionLabel.text = indexPath.row == 1 ? PTLanguage.share.text(forKey: "theme_Black") : darkTime
                cell.redView.isHidden = true
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withClass: DescriptionCustomViewCell.self, for: indexPath)
            cell.contentLabel.text = PTLanguage.share.text(forKey: "theme_SystemInfo")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                let contentHeight = UIView.sizeFor(string: PTLanguage.share.text(forKey: "theme_SmartInfo"), font: .appfont(size: 14), height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - 30).height + 20
                return contentHeight
            } else {
                return 44.0
            }
        } else if indexPath.section == 1 {
            let contentHeight = UIView.sizeFor(string: PTLanguage.share.text(forKey: "theme_SystemInfo"), font: .appfont(size: 14), height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH - 30).height + 18
            return contentHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.kSCREEN_WIDTH, height: 55))
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 100, height: 55))
        label.font = .appfont(size: 16)
        label.textColor = .gobalTextColor
        label.textAlignment = .left
        label.text = section == 0 ? PTLanguage.share.text(forKey: "theme_Smart") : PTLanguage.share.text(forKey: "theme_FollowSystem")
        sectionView.addSubview(label)
        
        let switchSetting = UISwitch(frame: CGRect(x: CGFloat.kSCREEN_WIDTH - 15 - 51, y: 0, width: 51, height: 55))
//        switchSetting.jk.centerY = label.jk.centerY
        switchSetting.isOn = section == 0 ? PTDrakModeOption.isSmartPeeling : PTDrakModeOption.isFollowSystem
        switchSetting.tag = section == 0 ? 100 : 101
        if section == 0 {
            switchSetting.onTintColor = PTDrakModeOption.isSmartPeeling ? UIColor.orange : UIColor.systemBlue
        } else {
            switchSetting.onTintColor = PTDrakModeOption.isFollowSystem ? UIColor.orange : UIColor.systemBlue
        }
        switchSetting.addTarget(self, action: #selector(switchClick), for: .touchUpInside)
        sectionView.addSubview(switchSetting)
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionFootView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.kSCREEN_WIDTH, height: 0.01))
        return sectionFootView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0, indexPath.row == 2 {
                        
            // 获取暗黑模式时间的区间，转为两个时间戳，取出当前的时间戳，看是否在区间内，在的话：黑色，否则白色
            let timeIntervalValue = PTDrakModeOption.smartPeelingTimeIntervalValue.separatedByString(with: PTLanguage.share.text(forKey: "picker_And"))
            let darkModePickerView = DarkModePickerView(startTime: timeIntervalValue[0], endTime: timeIntervalValue[1]) {[weak self] (startTime, endTime) in
                guard let weakSelf = self else { return }
                PTDrakModeOption.setSmartPeelingTimeChange(startTime: startTime, endTime: endTime)
                weakSelf.darkTime = startTime + PTLanguage.share.text(forKey: "picker_And") + endTime
                // 更新选择
                weakSelf.topHeadView.updateSelected()
                weakSelf.tableView.reloadData()
            }
            darkModePickerView.showTime()
        }
    }
}

// MARK: - 时间
extension PTDarkModeSettingViewController {
    // MARK: 开关
    @objc func switchClick(sender: UISwitch) {
        if sender.tag == 100 {
            // 智能换肤
            print("智能换肤-------\(sender.isOn)")
            PTDrakModeOption.setSmartPeelingDarkMode(isSmartPeeling: sender.isOn)
            sender.setOn(PTDrakModeOption.isSmartPeeling, animated: false)
            // 更新选择
            topHeadView.updateSelected()
            self.tableView.reloadData()
        } else {
            // 跟随系统
            print("跟随系统-------\(sender.isOn)")
            PTDrakModeOption.setDarkModeFollowSystem(isFollowSystem: sender.isOn)
            // label1.isHidden = sender.isOn
            // switch1.isHidden = sender.isOn
            sender.setOn(PTDrakModeOption.isFollowSystem, animated: false)
            // 更新选择
            topHeadView.updateSelected()
            self.tableView.reloadData()
        }
    }
}

extension PTDarkModeSettingViewController: PTThemeable {
    func apply() {
        tableView.backgroundColor = .gobalBackgroundColor
        self.tableView.reloadData()
        let type:VCStatusBarChangeStatusType = PTDrakModeOption.isLight ? .Light : .Dark
        self.changeStatusBar(type: type)
    }
}

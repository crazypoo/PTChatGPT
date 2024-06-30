//
//  PTDarkModeControl.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 20/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

class PTDarkModeControl: PTChatBaseViewController {

    private var darkTime: String = PTDarkModeOption.smartPeelingTimeIntervalValue
    
    var themeSetBlock: (()->Void)?

    lazy var darkModeControlArr : [[PTFusionCellModel]] = {
        let smart = PTFusionCellModel()
        smart.name = PTAppConfig.languageFunc(text: "theme_Smart")
        smart.nameColor = .gobalTextColor
        smart.accessoryType = .Switch
        
        let followSystem = PTFusionCellModel()
        followSystem.name = PTAppConfig.languageFunc(text: "theme_FollowSystem")
        followSystem.nameColor = .gobalTextColor
        followSystem.accessoryType = .Switch

        return [[smart],[followSystem]]
    }()
    
    var mSections = [PTSection]()
    
    lazy var collectionView : PTCollectionView = {
        let config = PTCollectionViewConfig()
        config.viewType = .Custom
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTFusionCell.ID:PTFusionCell.self])
        view.registerSupplementaryView(classs: [PTDarkModeHeader.ID:PTDarkModeHeader.self], kind: UICollectionView.elementKindSectionHeader)
        view.registerSupplementaryView(classs: [PTDarkSmartFooter.ID:PTDarkSmartFooter.self,PTDarkFollowSystemFooter.ID:PTDarkFollowSystemFooter.self], kind: UICollectionView.elementKindSectionFooter)
        view.headerInCollection = { kind,collectionView,sectionModel,indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionModel.headerID!, for: indexPath) as! PTDarkModeHeader
            header.currentMode = PTDarkModeOption.isLight ? .light : .dark
            header.selectModeBlock = { mode in
                PTDarkModeOption.setDarkModeCustom(isLight: mode == .light ? true : false)
                self.showDetail()
                if self.themeSetBlock != nil {
                    self.themeSetBlock!()
                }
            }
            return header
        }
        view.footerInCollection = { kind,collectionView,sectionModel,indexPath in
            if sectionModel.footerID == PTDarkSmartFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionModel.footerID!, for: indexPath) as! PTDarkSmartFooter
                footer.themeTimeButton.normalTitle = self.darkTime
                footer.themeTimeButton.addActionHandlers { sender in
                    let timeIntervalValue = PTDarkModeOption.smartPeelingTimeIntervalValue.separatedByString(with: "~")
                    let darkModePickerView = DarkModePickerView(startTime: timeIntervalValue[0], endTime: timeIntervalValue[1]) { (startTime, endTime) in
                        if startTime < endTime {
                            PTDarkModeOption.setSmartPeelingTimeChange(startTime: startTime, endTime: endTime)
                            self.darkTime = startTime + "~" + endTime
                            self.showDetail()
                        } else {
                            PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Time_set_error"))
                        }
                    }
                    darkModePickerView.showTime()
                }
                return footer
            } else if sectionModel.footerID == PTDarkFollowSystemFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionModel.footerID!, for: indexPath) as! PTDarkFollowSystemFooter
                return footer
            }
            return nil
        }
        view.customerLayout = { sectionIndex,sectionModel in
            var group : NSCollectionLayoutGroup
            let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
            
            var bannerGroupSize : NSCollectionLayoutSize
            var customers = [NSCollectionLayoutGroupCustomItem]()
            var groupH:CGFloat = 0
            var screenW:CGFloat = 0
            if Gobal_device_info.isPad {
                screenW = (CGFloat.kSCREEN_WIDTH - iPadSplitMainControl)
            } else {
                screenW = CGFloat.kSCREEN_WIDTH
            }
            var cellHeight:CGFloat = 0
            if Gobal_device_info.isPad {
                cellHeight = 64
            } else {
                cellHeight = CGFloat.ScaleW(w: 44)
            }
            sectionModel.rows.enumerated().forEach { (index,model) in
                let cellHeight:CGFloat = cellHeight
                let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: screenW - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
                customers.append(customItem)
                groupH += cellHeight
            }
            bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
            group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
                customers
            })
            return group
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cellModel = (itemRow.dataModel as! PTFusionCellModel)
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.cellModel = cellModel
//            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
//            cell.dataContent.topLineView.isHidden = true
//            cell.dataContent.backgroundColor = .gobalCellBackgroundColor
//            cell.dataContent.valueSwitch.onTintColor = .orange
            if cellModel.name == PTAppConfig.languageFunc(text: "theme_Smart") {
                cell.switchValue = PTDarkModeOption.isSmartPeeling
                PTGCDManager.gcdMain {
                    cell.contentView.viewCornerRectCorner(cornerRadii: 0, corner: .allCorners)
                }
            } else if cellModel.name == PTAppConfig.languageFunc(text: "theme_FollowSystem") {
                cell.switchValue = PTDarkModeOption.isFollowSystem
                PTGCDManager.gcdMain {
                    cell.contentView.viewCornerRectCorner(cornerRadii: 5, corner: [.bottomLeft,.bottomRight])
                }
            }
            cell.switchValueChangeBlock = { title,sender in
                if cellModel.name == PTAppConfig.languageFunc(text: "theme_Smart") {
                    PTDarkModeOption.setSmartPeelingDarkMode(isSmartPeeling: sender.isOn)
                    self.showDetail()
                } else if cellModel.name == PTAppConfig.languageFunc(text: "theme_FollowSystem") {
                    PTDarkModeOption.setDarkModeFollowSystem(isFollowSystem: sender.isOn)
                    self.showDetail()
                }
                if self.themeSetBlock != nil {
                    self.themeSetBlock!()
                }
            }
            
            return cell

        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTAppConfig.languageFunc(text: "theme_Title")
        
        // Do any additional setup after loading the view.
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        self.apply()
    }
    
    func showDetail() {
        mSections.removeAll()

        self.darkModeControlArr.enumerated().forEach { (index,value) in
            var rows = [PTRows]()
            value.enumerated().forEach { subIndex,subValue in
                let row = PTRows(ID: PTFusionCell.ID,dataModel: subValue)
                rows.append(row)
            }
            switch index {
            case 0:
                var sections:PTSection
                if PTDarkModeOption.isSmartPeeling {
                    sections = PTSection(headerID: PTDarkModeHeader.ID,footerID: PTDarkSmartFooter.ID,footerHeight: PTDarkSmartFooter.footerTotalHeight,headerHeight: PTDarkModeHeader.contentHeight + 10, rows: rows)
                } else {
                    sections = PTSection(headerID: PTDarkModeHeader.ID,headerHeight: PTDarkModeHeader.contentHeight + 10, rows: rows)
                }
                mSections.append(sections)
            case 1:
                var sections:PTSection
                if PTDarkModeOption.isFollowSystem {
                    sections = PTSection(footerID: PTDarkFollowSystemFooter.ID,footerHeight: PTDarkFollowSystemFooter.footerHeight, rows: rows)
                } else {
                    sections = PTSection(rows: rows)
                }
                mSections.append(sections)
            default:break
            }
        }
        
        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
}

extension PTDarkModeControl: PTThemeable {
    func apply() {
        self.view.backgroundColor = .gobalBackgroundColor
        self.showDetail()
        let type:VCStatusBarChangeStatusType = PTDarkModeOption.isLight ? .Light : .Dark
        self.changeStatusBar(type: type)
    }
}

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

    lazy var darkModeControlArr : [[PTFusionCellModel]] = {
        let smart = PTFusionCellModel()
        smart.name = PTLanguage.share.text(forKey: "theme_Smart")
        smart.nameColor = .gobalTextColor
        smart.haveSwitch = true
        
        let followSystem = PTFusionCellModel()
        followSystem.name = PTLanguage.share.text(forKey: "theme_FollowSystem")
        followSystem.nameColor = .gobalTextColor
        followSystem.haveSwitch = true
        
        return [[smart],[followSystem]]
    }()
    
    var mSections = [PTSection]()
    func comboLayout()->UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout.init { section, environment in
            self.generateSection(section: section)
        }
        layout.register(PTBaseDecorationView_Corner.self, forDecorationViewOfKind: "background")
        layout.register(PTBaseDecorationView.self, forDecorationViewOfKind: "background_no")
        return layout
    }
    
    func generateSection(section:NSInteger)->NSCollectionLayoutSection {
        let sectionModel = mSections[section]

        var group : NSCollectionLayoutGroup
        let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
        
        var bannerGroupSize : NSCollectionLayoutSize
        var customers = [NSCollectionLayoutGroupCustomItem]()
        var groupH:CGFloat = 0
        sectionModel.rows.enumerated().forEach { (index,model) in
            let cellHeight:CGFloat = CGFloat.ScaleW(w: 44)
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
            customers.append(customItem)
            groupH += cellHeight
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
        group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
            customers
        })
        
        let sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        if sectionModel.headerID == PTDarkModeHeader.ID {
            let headerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.headerHeight ?? CGFloat.leastNormalMagnitude))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topTrailing)
            
            let footerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.footerHeight ?? CGFloat.leastNormalMagnitude))
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing)

            if PTDarkModeOption.isSmartPeeling {
                laySection.boundarySupplementaryItems = [headerItem,footerItem]
            } else {
                laySection.boundarySupplementaryItems = [headerItem]
            }
        } else if sectionModel.footerID == PTDarkFollowSystemFooter.ID {
            let footerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.footerHeight ?? CGFloat.leastNormalMagnitude))
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing)
            laySection.boundarySupplementaryItems = [footerItem]
        }
        
        laySection.supplementariesFollowContentInsets = false

        return laySection
    }

    lazy var collectionView : UICollectionView = {
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: self.comboLayout())
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTLanguage.share.text(forKey: "theme_Title")
        
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
                let row = PTRows(cls:PTFusionCell.self,ID: PTFusionCell.ID,dataModel: subValue)
                rows.append(row)
            }
            switch index {
            case 0:
                var sections:PTSection
                if PTDarkModeOption.isSmartPeeling {
                    sections = PTSection(headerCls: PTDarkModeHeader.self,headerID: PTDarkModeHeader.ID,footerCls: PTDarkSmartFooter.self,footerID: PTDarkSmartFooter.ID,footerHeight: PTDarkSmartFooter.footerTotalHeight,headerHeight: PTDarkModeHeader.contentHeight + 10, rows: rows)
                } else {
                    sections = PTSection(headerCls: PTDarkModeHeader.self,headerID: PTDarkModeHeader.ID,headerHeight: PTDarkModeHeader.contentHeight + 10, rows: rows)
                }
                mSections.append(sections)
            case 1:
                var sections:PTSection
                if PTDarkModeOption.isFollowSystem {
                    sections = PTSection(footerCls: PTDarkFollowSystemFooter.self,footerID: PTDarkFollowSystemFooter.ID,footerHeight: PTDarkFollowSystemFooter.footerHeight, rows: rows)
                } else {
                    sections = PTSection(rows: rows)
                }
                mSections.append(sections)
            default:break
            }
        }
        
        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }

}

extension PTDarkModeControl:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionHeader {
            if itemSec.headerID == PTDarkModeHeader.ID {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.headerID!, for: indexPath) as! PTDarkModeHeader
                header.currentMode = PTDarkModeOption.isLight ? .light : .dark
                header.selectModeBlock = { mode in
                    PTDarkModeOption.setDarkModeCustom(isLight: mode == .light ? true : false)
                    self.showDetail()
                }
                return header
            }
            return UICollectionReusableView()
        } else if kind == UICollectionView.elementKindSectionFooter {
            if itemSec.footerID == PTDarkSmartFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTDarkSmartFooter
                footer.themeTimeButton.setTitle(darkTime, for: .normal)
                footer.themeTimeButton.addActionHandlers { sender in
                    let timeIntervalValue = PTDarkModeOption.smartPeelingTimeIntervalValue.separatedByString(with: "~")
                    let darkModePickerView = DarkModePickerView(startTime: timeIntervalValue[0], endTime: timeIntervalValue[1]) { (startTime, endTime) in
                        if startTime < endTime {
                            PTDarkModeOption.setSmartPeelingTimeChange(startTime: startTime, endTime: endTime)
                            self.darkTime = startTime + "~" + endTime
                            self.showDetail()
                        } else {
                            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Time_set_error"))
                        }
                    }
                    darkModePickerView.showTime()
                }
                return footer
            }
            else if itemSec.footerID == PTDarkFollowSystemFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTDarkFollowSystemFooter
                return footer
            }
            return UICollectionReusableView()
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTFusionCell.ID {
            let cellModel = (itemRow.dataModel as! PTFusionCellModel)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.cellModel = cellModel
            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.topLineView.isHidden = true
            cell.dataContent.backgroundColor = .gobalCellBackgroundColor
            cell.dataContent.valueSwitch.onTintColor = .orange
            if cellModel.name == PTLanguage.share.text(forKey: "theme_Smart") {
                cell.dataContent.valueSwitch.isOn = PTDarkModeOption.isSmartPeeling
                PTGCDManager.gcdMain {
                    cell.contentView.viewCornerRectCorner(cornerRadii: 0, corner: .allCorners)
                }
            } else if cellModel.name == PTLanguage.share.text(forKey: "theme_FollowSystem") {
                cell.dataContent.valueSwitch.isOn = PTDarkModeOption.isFollowSystem
                PTGCDManager.gcdMain {
                    cell.contentView.viewCornerRectCorner(cornerRadii: 5, corner: [.bottomLeft,.bottomRight])
                }
            }
            cell.dataContent.valueSwitch.addSwitchAction { sender in
                if cellModel.name == PTLanguage.share.text(forKey: "theme_Smart") {
                    PTDarkModeOption.setSmartPeelingDarkMode(isSmartPeeling: sender.isOn)
                    self.showDetail()
                } else if cellModel.name == PTLanguage.share.text(forKey: "theme_FollowSystem") {
                    PTDarkModeOption.setDarkModeFollowSystem(isFollowSystem: sender.isOn)
                    self.showDetail()
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
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

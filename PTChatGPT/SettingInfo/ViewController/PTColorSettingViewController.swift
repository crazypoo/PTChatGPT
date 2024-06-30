//
//  PTColorSettingViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import ChromaColorPicker

class PTColorSettingViewController: PTChatBaseViewController {

    private var currentColorName:String = ""
    
    func aboutModels() -> [PTSettingModels] {
        
        let disclosureIndicatorImageName = UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal)

        let colorMain = PTSettingModels()
        colorMain.name = PTAppConfig.languageFunc(text: "alert_Info")
        
        let userBubbleInfo = PTFusionCellModel()
        userBubbleInfo.name = PTAppConfig.languageFunc(text: "color_Bubble_user")
        userBubbleInfo.nameColor = .gobalTextColor
        userBubbleInfo.leftImage = UIImage(systemName: "bubble.left.fill")!.withRenderingMode(.automatic)
        userBubbleInfo.accessoryType = .DisclosureIndicator
        userBubbleInfo.contentIcon = AppDelegate.appDelegate()?.appConfig.userBubbleColor.createImageWithColor().transformImage(size: CGSizeMake(44, 44))
        userBubbleInfo.disclosureIndicatorImage = disclosureIndicatorImageName
        
        let botBubbleInfo = PTFusionCellModel()
        botBubbleInfo.name = PTAppConfig.languageFunc(text: "color_Bubble_bot")
        botBubbleInfo.nameColor = .gobalTextColor
        botBubbleInfo.leftImage = UIImage(systemName: "bubble.right.fill")!.withRenderingMode(.automatic)
        botBubbleInfo.accessoryType = .DisclosureIndicator
        botBubbleInfo.disclosureIndicatorImage = disclosureIndicatorImageName
        botBubbleInfo.contentIcon = AppDelegate.appDelegate()?.appConfig.botBubbleColor.createImageWithColor().transformImage(size: CGSizeMake(44, 44))

        let userTextInfo = PTFusionCellModel()
        userTextInfo.name = PTAppConfig.languageFunc(text: "color_Text_user")
        userTextInfo.nameColor = .gobalTextColor
        userTextInfo.leftImage = UIImage(systemName: "plus.bubble.fill")!.withRenderingMode(.automatic)
        userTextInfo.accessoryType = .DisclosureIndicator
        userTextInfo.disclosureIndicatorImage = disclosureIndicatorImageName
        userTextInfo.contentIcon = AppDelegate.appDelegate()?.appConfig.userTextColor.createImageWithColor().transformImage(size: CGSizeMake(44, 44))

        let botTextInfo = PTFusionCellModel()
        botTextInfo.name = PTAppConfig.languageFunc(text: "color_Text_bot")
        botTextInfo.nameColor = .gobalTextColor
        botTextInfo.leftImage = UIImage(systemName: "text.bubble.fill")!.withRenderingMode(.automatic)
        botTextInfo.accessoryType = .DisclosureIndicator
        botTextInfo.disclosureIndicatorImage = disclosureIndicatorImageName
        botTextInfo.contentIcon = AppDelegate.appDelegate()?.appConfig.botTextColor.createImageWithColor().transformImage(size: CGSizeMake(44, 44))

        let waveInfo = PTFusionCellModel()
        waveInfo.name = PTAppConfig.languageFunc(text: "color_Wave")
        waveInfo.nameColor = .gobalTextColor
        waveInfo.leftImage = UIImage(systemName: "waveform")!.withRenderingMode(.automatic)
        waveInfo.accessoryType = .DisclosureIndicator
        waveInfo.disclosureIndicatorImage = disclosureIndicatorImageName
        waveInfo.contentIcon = AppDelegate.appDelegate()?.appConfig.waveColor.createImageWithColor().transformImage(size: CGSizeMake(44, 44))

        if self.user.senderId == PTChatData.share.bot.senderId {
            colorMain.models = [botBubbleInfo,botTextInfo]
        } else if self.user.senderId == PTChatData.share.user.senderId {
            colorMain.models = [userBubbleInfo,userTextInfo,waveInfo]
        } else {
            colorMain.models = [userBubbleInfo,botBubbleInfo,userTextInfo,botTextInfo,waveInfo]
        }
        
        return [colorMain]
    }
                
    var mSections = [PTSection]()
    
    lazy var collectionView : PTCollectionView = {
        
        let decorationModel = PTDecorationItemModel()
        decorationModel.decorationID = PTBaseDecorationView_Corner.ID
        decorationModel.decorationClass = PTBaseDecorationView_Corner.self
        
        let config = PTCollectionViewConfig()
        config.viewType = .Custom
        config.decorationModel = [decorationModel]
        config.decorationItemsEdges = NSDirectionalEdgeInsets(top: 10, leading: PTAppBaseConfig.share.defaultViewSpace, bottom: 0, trailing: PTAppBaseConfig.share.defaultViewSpace)
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTFusionCell.ID:PTFusionCell.self])
        view.customerLayout = { sectionIndex,sectionModel in
            var group : NSCollectionLayoutGroup
            let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
            
            var bannerGroupSize : NSCollectionLayoutSize
            var customers = [NSCollectionLayoutGroupCustomItem]()
            var groupH:CGFloat = 0
            var cellHeight:CGFloat = 54
            var screenW:CGFloat = CGFloat.kSCREEN_WIDTH
            if Gobal_device_info.isPad {
                cellHeight = 54
                screenW = CGFloat.kSCREEN_WIDTH - iPadSplitMainControl
            } else {
                cellHeight = 54
                screenW = CGFloat.kSCREEN_WIDTH
            }
            sectionModel.rows.enumerated().forEach { (index,model) in
                let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: screenW - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
                customers.append(customItem)
                groupH += cellHeight
            }
            bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
            group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
                customers
            })

            return group
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
    //        cell.dataContent.lineView.isHidden = true
    //        cell.dataContent.topLineView.isHidden = (indexPath.row == 0) ? true : false
            return cell
        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            if itemRow.title == PTAppConfig.languageFunc(text: "color_Bubble_user") {
                self.colorPicker(color: AppDelegate.appDelegate()!.appConfig.userBubbleColor)
            } else if itemRow.title == PTAppConfig.languageFunc(text: "color_Bubble_bot") {
                self.colorPicker(color: AppDelegate.appDelegate()!.appConfig.botBubbleColor)
            } else if itemRow.title == PTAppConfig.languageFunc(text: "color_Text_user") {
                self.colorPicker(color: AppDelegate.appDelegate()!.appConfig.userTextColor)
            } else if itemRow.title == PTAppConfig.languageFunc(text: "color_Text_bot") {
                self.colorPicker(color: AppDelegate.appDelegate()!.appConfig.botTextColor)
            } else if itemRow.title == PTAppConfig.languageFunc(text: "color_Wave") {
                self.colorPicker(color: AppDelegate.appDelegate()!.appConfig.waveColor)
            }

            self.currentColorName = itemRow.title
        }
        return view
    }()
        
    init(user:PTChatUser) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zx_navTitle = PTAppConfig.languageFunc(text: "color_Setting")
        if Gobal_device_info.isPad {
            self.isModalInPresentation = true
            self.zx_navFixFrame = CGRect(x: 0, y: 0, width: 400, height: 54)
        }
        
        self.view.addSubviews([self.collectionView])
        
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }

        self.showDetail()
    }

    func showDetail() {
        mSections.removeAll()

        self.aboutModels().enumerated().forEach { (index,value) in
            var rows = [PTRows]()
            value.models.enumerated().forEach { (subIndex,subValue) in
                let row_List = PTRows.init(title: subValue.name, ID: PTFusionCell.ID, dataModel: subValue)
                rows.append(row_List)
            }
            let cellSection = PTSection.init(rows: rows)
            mSections.append(cellSection)
        }
        
        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
                
    func colorPicker(color:UIColor) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        
        // 设置预选颜色
        colorPicker.selectedColor = color
        
        // 显示 alpha 通道
        colorPicker.supportsAlpha = true
        
        colorPicker.modalPresentationStyle = .fullScreen
        // 呈现颜色选择器
        if Gobal_device_info.isPad {
            colorPicker.modalPresentationStyle = .formSheet
            colorPicker.preferredContentSize = CGSize(width: 400, height: CGFloat.kSCREEN_HEIGHT)
            self.splitViewController?.present(colorPicker, animated: true)
        } else {
            colorPicker.modalPresentationStyle = .formSheet
            self.present(colorPicker, animated: true)
        }
    }
    
    func colorPickerSelectedColor(selectedColor:UIColor) {
        if self.currentColorName == PTAppConfig.languageFunc(text: "color_Bubble_user") {
            AppDelegate.appDelegate()!.appConfig.userBubbleColor = selectedColor
        } else if self.currentColorName == PTAppConfig.languageFunc(text: "color_Bubble_bot") {
            AppDelegate.appDelegate()!.appConfig.botBubbleColor = selectedColor
        } else if self.currentColorName == PTAppConfig.languageFunc(text: "color_Text_user") {
            AppDelegate.appDelegate()!.appConfig.userTextColor = selectedColor
        } else if self.currentColorName == PTAppConfig.languageFunc(text: "color_Text_bot") {
            AppDelegate.appDelegate()!.appConfig.botTextColor = selectedColor
        } else if self.currentColorName == PTAppConfig.languageFunc(text: "color_Wave") {
            AppDelegate.appDelegate()!.appConfig.waveColor = selectedColor
        }
        
        self.showDetail()
    }
}

extension PTColorSettingViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // 用户完成选择后执行的操作
        let selectedColor = viewController.selectedColor
        self.colorPickerSelectedColor(selectedColor: selectedColor)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        // 当用户选择颜色时执行的操作
        let selectedColor = viewController.selectedColor
        self.colorPickerSelectedColor(selectedColor: selectedColor)
    }
}

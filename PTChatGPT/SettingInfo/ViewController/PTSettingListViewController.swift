//
//  PTSettingListViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import BRPickerView
import Photos
import FloatingPanel
import ZXNavigationBar
import FDFullscreenPopGesture
import SwiftSpinner
import OSSSpeechKit

//MARK: iCloud
let SettingCloudString = "iCloud"
let SettingGithub = PTLanguage.share.text(forKey: "Github")
let SettingHelp = PTLanguage.share.text(forKey: "about_Help")

class PTChatPanelLayout: FloatingPanelLayout {
    
    public var viewHeight:CGFloat = 18
    
    open var initialState: FloatingPanelState {
        .full
    }

    open var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring]  {
        [
            .full: FloatingPanelLayoutAnchor(absoluteInset: CGFloat.kSCREEN_HEIGHT - viewHeight, edge: .top, referenceGuide: .superview)
        ]
    }

    open var position: FloatingPanelPosition {
        .bottom
    }

    open func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.45
    }
}

class PTSettingListViewController: PTChatBaseViewController {

    ///获取下载信息
    var downloadInfo = AppDelegate.appDelegate()!.appConfig.getDownloadInfomation()
    
    lazy var currentSettingViewController:PTSettingListViewController = {
        if let splitViewController = self.splitViewController,
            let detailViewController = splitViewController.viewControllers.last as? PTNavController {
            // 在这里使用detailViewController
            let chat = detailViewController.viewControllers.last as! PTSettingListViewController
            return chat
        } else if let detailViewController = self.navigationController?.viewControllers.last as? PTNavController {
            // 在这里使用detailViewController
            let chat = detailViewController.viewControllers.last as! PTSettingListViewController
            return chat
        } else {
            return PTSettingListViewController(user: PTChatUser(senderId: "0", displayName: "0"))
        }
    }()
    
    var currentChatModel:PTSegHistoryModel?
    
    var cleanChatListBlock:(()->Void)?
    
    enum LanguageKey : String {
        case ChineseHans = "zh-Hans"
        case ChineseHK = "zh-HK"
        case English = "en"
        case Spanish = "es"
        
        static var allValues : [LanguageKey] {
            return [.ChineseHans, .ChineseHK, .English,.Spanish]
        }
        
        var desc:String {
            switch self {
            case .ChineseHans:
                return "中文(简体)"
            case .ChineseHK:
                return "中文(繁体)"
            case .English:
                return "English"
            case .Spanish:
                return "Español"
            }
        }
        
        static var allNames : [String] {
            var values = [String]()
            self.allValues.enumerated().forEach { index,value in
                values.append(value.desc)
            }
            return values
        }
    }
    
    lazy var currentSelectedLanguage : String = {
        let string = LanguageKey(rawValue: PTLanguage.share.language)!.desc
        return string
    }()

    lazy var languagePicker:BRStringPickerView = {
        let picker = BRStringPickerView(pickerMode: .componentSingle)
        picker.pickerStyle = PTAppConfig.gobal_BRPickerStyle()

        return picker
    }()

    lazy var AIModelPicker:BRStringPickerView = {
        let picker = BRStringPickerView(pickerMode: .componentLinkage)
        AppDelegate.appDelegate()!.appConfig.getAiModelPickerDate(currentAi: AppDelegate.appDelegate()!.appConfig.aiModelType,currentChatModel: self.currentChatModel) { result, selectIndex in
            picker.dataSourceArr = result
            picker.selectIndexs = selectIndex
        }
        picker.numberOfComponents = 2
        picker.resultModelArrayBlock = { resultModel in
            AppDelegate.appDelegate()!.appConfig.aiModelType = resultModel!.last!.value!
            self.showDetail()
        }
        picker.pickerStyle = PTAppConfig.gobal_BRPickerStyle()
        picker.title = PTLanguage.share.text(forKey: "about_APIAIType")
        return picker
    }()
        
    func cellContentAtt(content:String) -> NSMutableAttributedString {
        let att = NSMutableAttributedString.sj.makeText { make in
            make.append(content).font(.appfont(size: 14)).alignment(.right).textColor(.gobalTextColor)
        }
        return att as! NSMutableAttributedString
    }
    
    func aboutModels() -> [PTSettingModels] {
        let disclosureIndicatorImageName = UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal)
        let nameFont:UIFont = .appfont(size: 16,bold: true)

        let switchColor = UIColor.orange
        
        let cloudMain = PTSettingModels()
        cloudMain.name = "iCloud"
        
        let cloud = PTFusionCellModel()
        cloud.name = SettingCloudString
//        cloud.leftImage = "☁️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        cloud.haveSwitch = true
        cloud.nameColor = .gobalTextColor
        cloud.cellFont = nameFont
        cloud.switchTinColor = switchColor

        cloudMain.models = [cloud]

        let themeMain = PTSettingModels()
        themeMain.name = PTLanguage.share.text(forKey: "about_Main_Theme")
        
        //MARK: 主題
        let color = PTFusionCellModel()
        color.name = PTLanguage.share.text(forKey: "about_Color")
//        color.leftImage = "🎨".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        color.haveDisclosureIndicator = true
        color.nameColor = .gobalTextColor
        color.disclosureIndicatorImage = disclosureIndicatorImageName
        color.cellFont = nameFont

        let language = PTFusionCellModel()
        language.name = PTLanguage.share.text(forKey: "about_Language")
//        language.leftImage = "🚩".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        language.haveDisclosureIndicator = true
        language.nameColor = .gobalTextColor
        language.disclosureIndicatorImage = disclosureIndicatorImageName
        language.cellFont = nameFont
        language.contentAttr = self.cellContentAtt(content: self.currentSelectedLanguage)

        let theme = PTFusionCellModel()
        theme.name = PTLanguage.share.text(forKey: "about_Main_Theme")
//        theme.leftImage = "🖼️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        theme.haveDisclosureIndicator = true
        theme.nameColor = .gobalTextColor
        theme.disclosureIndicatorImage = disclosureIndicatorImageName
        theme.cellFont = nameFont
        
        var themeCurrent = ""
        if PTDarkModeOption.isSmartPeeling {
            themeCurrent = PTLanguage.share.text(forKey: "theme_Smart")
        } else if PTDarkModeOption.isFollowSystem {
            themeCurrent = PTLanguage.share.text(forKey: "theme_FollowSystem")
        } else {
            themeCurrent = PTDarkModeOption.isLight ? PTLanguage.share.text(forKey: "theme_White") : PTLanguage.share.text(forKey: "theme_Black")
        }
        
        theme.contentAttr = self.cellContentAtt(content: themeCurrent)

        let userIcon = PTFusionCellModel()
        userIcon.name = PTLanguage.share.text(forKey: "about_User_icon")
//        userIcon.leftImage = "🤳".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        userIcon.showContentIcon = true
        userIcon.contentIcon = UIImage(data: AppDelegate.appDelegate()!.appConfig.userIcon)
        userIcon.haveDisclosureIndicator = true
        userIcon.nameColor = .gobalTextColor
        userIcon.disclosureIndicatorImage = disclosureIndicatorImageName
        userIcon.cellFont = nameFont
        
        let userName = PTFusionCellModel()
        userName.name = PTLanguage.share.text(forKey: "about_User_name")
        userName.haveDisclosureIndicator = true
        userName.nameColor = .gobalTextColor
        userName.disclosureIndicatorImage = disclosureIndicatorImageName
        userName.cellFont = nameFont
        userName.contentAttr = self.cellContentAtt(content: AppDelegate.appDelegate()!.appConfig.userName)

        if self.user.senderId == PTChatData.share.bot.senderId {
            themeMain.models = [color]
        } else if self.user.senderId == PTChatData.share.user.senderId {
            if Gobal_device_info.isPad {
                themeMain.models = [color]
            } else {
                themeMain.models = [color,userIcon,userName]
            }
        } else {
            if Gobal_device_info.isPad {
                themeMain.models = [color,language,theme]
            } else {
                themeMain.models = [color,userIcon,userName,language,theme]
            }
        }
        
        //MARK: Speech
        let speechMain = PTSettingModels()
        speechMain.name = PTLanguage.share.text(forKey: "about_Main_Speech")

        let speechLanguage = PTFusionCellModel()
        speechLanguage.name = PTLanguage.share.text(forKey: "about_Main_Speech")
//        speechLanguage.leftImage = "🎙️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        speechLanguage.haveDisclosureIndicator = true
        speechLanguage.nameColor = .gobalTextColor
        speechLanguage.disclosureIndicatorImage = disclosureIndicatorImageName
        speechLanguage.cellFont = nameFont
        speechLanguage.contentAttr = self.cellContentAtt(content: AppDelegate.appDelegate()!.appConfig.language)

        speechMain.models = [speechLanguage]

        //MARK: Chat
        let chatMain = PTSettingModels()
        chatMain.name = "Chat"

        let savedMessage = PTFusionCellModel()
        savedMessage.name = PTLanguage.share.text(forKey: "about_SavedChat")
//        savedMessage.leftImage = "📑".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        savedMessage.haveDisclosureIndicator = true
        savedMessage.nameColor = .gobalTextColor
        savedMessage.disclosureIndicatorImage = disclosureIndicatorImageName
        savedMessage.cellFont = nameFont
        savedMessage.contentAttr = self.cellContentAtt(content: "\(AppDelegate.appDelegate()!.appConfig.getSaveChatData().count)")

        let deleteAllChat = PTFusionCellModel()
        deleteAllChat.name = PTLanguage.share.text(forKey: "about_DeleteAllChat")
//        deleteAllChat.leftImage = "🗑️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        deleteAllChat.haveDisclosureIndicator = true
        deleteAllChat.nameColor = .gobalTextColor
        deleteAllChat.disclosureIndicatorImage = disclosureIndicatorImageName
        deleteAllChat.cellFont = nameFont

        let deleteAllVoiceFile = PTFusionCellModel()
        deleteAllVoiceFile.name = PTLanguage.share.text(forKey: "about_Delete_all_voice_file")
//        deleteAllVoiceFile.leftImage = "🔇".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        deleteAllVoiceFile.haveDisclosureIndicator = true
        deleteAllVoiceFile.nameColor = .gobalTextColor
        deleteAllVoiceFile.disclosureIndicatorImage = disclosureIndicatorImageName
        deleteAllVoiceFile.cellFont = nameFont

        chatMain.models = [savedMessage,deleteAllChat,deleteAllVoiceFile]
        
        let apiMain = PTSettingModels()
        apiMain.name = "AI"

        //MARK: AI
        let aiName = PTFusionCellModel()
        aiName.name = PTLanguage.share.text(forKey: "about_AI_name")
        aiName.haveDisclosureIndicator = true
        aiName.nameColor = .gobalTextColor
        aiName.disclosureIndicatorImage = disclosureIndicatorImageName
        aiName.cellFont = nameFont
        aiName.contentAttr = self.cellContentAtt(content: AppDelegate.appDelegate()!.appConfig.aiName)

        let aiType = PTFusionCellModel()
        aiType.name = PTLanguage.share.text(forKey: "about_APIAIType")
//        aiType.leftImage = "🤖".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        aiType.haveDisclosureIndicator = true
        aiType.nameColor = .gobalTextColor
        aiType.disclosureIndicatorImage = disclosureIndicatorImageName
        aiType.cellFont = nameFont
        aiType.contentAttr = self.cellContentAtt(content: AppDelegate.appDelegate()!.appConfig.aiModelType)

        let aiSmart = PTFusionCellModel()
        aiSmart.name = PTLanguage.share.text(forKey: "about_AI_smart")
        aiSmart.nameColor = .gobalTextColor
//        aiSmart.leftImage = "🧠".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        aiSmart.cellFont = nameFont

        let drawSize = PTFusionCellModel()
        drawSize.name = PTLanguage.share.text(forKey: "about_Draw_image_size")
//        drawSize.leftImage = "📏".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        drawSize.haveDisclosureIndicator = true
        drawSize.nameColor = .gobalTextColor
        var sizeString = ""
        switch AppDelegate.appDelegate()!.appConfig.aiDrawSize.width {
        case 1024:
            sizeString = PTOpenAIImageSize.size1024.rawValue
        case 512:
            sizeString = PTOpenAIImageSize.size512.rawValue
        default:
            sizeString = PTOpenAIImageSize.size256.rawValue
        }
        drawSize.disclosureIndicatorImage = disclosureIndicatorImageName
        drawSize.cellFont = nameFont
        drawSize.contentAttr = self.cellContentAtt(content: sizeString)

        let imageCount = PTFusionCellModel()
        imageCount.name = PTLanguage.share.text(forKey: "chat_Get_image_count")
//        imageCount.leftImage = "🎆".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        imageCount.haveDisclosureIndicator = true
        imageCount.nameColor = .gobalTextColor
        imageCount.disclosureIndicatorImage = disclosureIndicatorImageName
        imageCount.cellFont = nameFont
        imageCount.contentAttr = self.cellContentAtt(content: "\(AppDelegate.appDelegate()!.appConfig.getImageCount)")

        let drawSample = PTFusionCellModel()
        drawSample.name = PTLanguage.share.text(forKey: "draw_Reference")
//        drawSample.leftImage = "🎇".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        drawSample.showContentIcon = true
        drawSample.contentIcon = UIImage(data: AppDelegate.appDelegate()!.appConfig.drawRefrence)
        drawSample.haveDisclosureIndicator = true
        drawSample.nameColor = .gobalTextColor
        drawSample.disclosureIndicatorImage = disclosureIndicatorImageName
        drawSample.cellFont = nameFont

        let aiToken = PTFusionCellModel()
        aiToken.name = PTLanguage.share.text(forKey: "about_APIAIToken")
//        aiToken.leftImage = "🔑".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        aiToken.haveDisclosureIndicator = true
        aiToken.nameColor = .gobalTextColor
        aiToken.disclosureIndicatorImage = disclosureIndicatorImageName
        aiToken.cellFont = nameFont

        let getApiToken = PTFusionCellModel()
        getApiToken.name = PTLanguage.share.text(forKey: "about_GetAPIAIToken")
//        getApiToken.leftImage = "🧭".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        getApiToken.haveDisclosureIndicator = true
        getApiToken.nameColor = .gobalTextColor
        getApiToken.disclosureIndicatorImage = disclosureIndicatorImageName
        getApiToken.cellFont = nameFont
        
        let domainSwitch = PTFusionCellModel()
        domainSwitch.name = PTLanguage.share.text(forKey: "about_Use_custom_domain_switch")
        domainSwitch.nameColor = .gobalTextColor
        domainSwitch.haveSwitch = true
        domainSwitch.switchTinColor = switchColor
        domainSwitch.cellFont = nameFont

        let domainAddress = PTFusionCellModel()
        domainAddress.name = PTLanguage.share.text(forKey: "about_Use_custom_domain_address")
        domainAddress.haveDisclosureIndicator = true
        domainAddress.nameColor = .gobalTextColor
        domainAddress.disclosureIndicatorImage = disclosureIndicatorImageName
        domainAddress.cellFont = nameFont
        domainAddress.contentAttr = self.cellContentAtt(content: AppDelegate.appDelegate()!.appConfig.customDomain)

        if self.user.senderId == PTChatData.share.bot.senderId {
            apiMain.models = [aiName,aiType,aiSmart,drawSize,imageCount,drawSample,aiToken,domainSwitch,domainAddress]
        } else {
            apiMain.models = [aiName,aiType,aiSmart,drawSize,imageCount,drawSample,aiToken,getApiToken,domainSwitch,domainAddress]
        }
        
        let stableDiffusionMain = PTSettingModels()
        stableDiffusionMain.name = PTLanguage.share.text(forKey: "Stable Diffusion Model")

        var diffusionModels = [PTFusionCellModel]()
        self.downloadInfo.enumerated().forEach { index,value in
            let modiModel = PTFusionCellModel()
            modiModel.name = value!.name
            modiModel.nameColor = .gobalTextColor
            modiModel.content = value!.folderName
            modiModel.cellFont = nameFont
            diffusionModels.append(modiModel)
        }
        
        stableDiffusionMain.models = diffusionModels

        let toolMain = PTSettingModels()
        toolMain.name = PTLanguage.share.text(forKey: "setting_Tool")
        
        let reset = PTFusionCellModel()
        reset.name = PTLanguage.share.text(forKey: "setting_Reset")
//        reset.leftImage = "🔄".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        reset.haveDisclosureIndicator = true
        reset.nameColor = .gobalTextColor
        reset.disclosureIndicatorImage = disclosureIndicatorImageName
        reset.cellFont = nameFont

        toolMain.models = [reset]
        
        let otherMain = PTSettingModels()
        otherMain.name = PTLanguage.share.text(forKey: "about_Main_Other")

        //MARK: Other
        let github = PTFusionCellModel()
        github.name = PTLanguage.share.text(forKey: "Github")
//        github.leftImage = "🐙".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        github.haveDisclosureIndicator = true
        github.nameColor = .gobalTextColor
        github.disclosureIndicatorImage = disclosureIndicatorImageName
        github.cellFont = nameFont

        let forum = PTFusionCellModel()
        forum.name = PTLanguage.share.text(forKey: "about_Forum")
//        forum.leftImage = "🧾".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        forum.haveDisclosureIndicator = true
        forum.nameColor = .gobalTextColor
        forum.disclosureIndicatorImage = disclosureIndicatorImageName
        forum.cellFont = nameFont

        let rate = PTFusionCellModel()
        rate.name = PTLanguage.share.text(forKey: "about_Rate")
//        rate.leftImage = "⭐️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        rate.haveDisclosureIndicator = true
        rate.nameColor = .gobalTextColor
        rate.disclosureIndicatorImage = disclosureIndicatorImageName
        rate.cellFont = nameFont

        let share = PTFusionCellModel()
        share.name = PTLanguage.share.text(forKey: "about_Share")
//        share.leftImage = "💁‍♂️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        share.haveDisclosureIndicator = true
        share.nameColor = .gobalTextColor
        share.disclosureIndicatorImage = disclosureIndicatorImageName
        share.cellFont = nameFont
        
        let help = PTFusionCellModel()
        help.name = PTLanguage.share.text(forKey: "about_Help")
//        share.leftImage = "💁‍♂️".emojiToImage(emojiFont: .appfont(size: 24)).transformImage(size: CGSize(width: 34, height: 34))
        help.haveDisclosureIndicator = true
        help.nameColor = .gobalTextColor
        help.disclosureIndicatorImage = disclosureIndicatorImageName
        help.cellFont = nameFont

        otherMain.models = [github,forum,rate,share,help]
        
        if self.user.senderId == PTChatData.share.bot.senderId {
            return [themeMain,apiMain]
        } else if self.user.senderId == PTChatData.share.user.senderId {
            return [themeMain,speechMain]
        } else {
            if AppDelegate.appDelegate()!.appConfig.canUseStableDiffusionModel() {
                return [cloudMain,themeMain,speechMain,chatMain,apiMain,stableDiffusionMain,toolMain,otherMain]
            } else {
                return [cloudMain,themeMain,speechMain,chatMain,apiMain,toolMain,otherMain]
            }
        }
    }
    
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
        var screenW:CGFloat = 0
        if Gobal_device_info.isPad {
            screenW = (CGFloat.kSCREEN_WIDTH - iPadSplitMainControl)
        } else {
            screenW = CGFloat.kSCREEN_WIDTH
        }
        sectionModel.rows.enumerated().forEach { (index,model) in
            var cellHeight:CGFloat = 0
            if Gobal_device_info.isPad {
                cellHeight = 54
            } else {
                cellHeight = CGFloat.ScaleW(w: 44)
            }
            if (model.dataModel as! PTFusionCellModel).name == PTLanguage.share.text(forKey: "about_AI_smart") {
                if Gobal_device_info.isPad {
                    cellHeight = 98
                } else {
                    cellHeight = CGFloat.ScaleW(w: 98)
                }
            }
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: screenW - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
            customers.append(customItem)
            groupH += cellHeight
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
        group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
            customers
        })
        
        var sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        var laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        sectionInsets = NSDirectionalEdgeInsets.init(top: 10, leading: 0, bottom: 0, trailing: 0)
        laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        let headerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.headerHeight ?? CGFloat.leastNormalMagnitude))
        let footerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.footerHeight ?? CGFloat.leastNormalMagnitude))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topTrailing)
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing)
        if sectionModel.headerTitle == PTLanguage.share.text(forKey: "about_Main_Other") {
            laySection.boundarySupplementaryItems = [headerItem,footerItem]
        } else {
            laySection.boundarySupplementaryItems = [headerItem]
        }

        return laySection
    }

    lazy var collectionView : UICollectionView = {
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: self.comboLayout())
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    init(user:PTChatUser) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user.senderId == PTChatData.share.bot.senderId {
            self.zx_navTitle = "ZolaAi " + PTLanguage.share.text(forKey: "about_Setting")
        } else if self.user.senderId == PTChatData.share.user.senderId {
            self.zx_navTitle = PTLanguage.share.text(forKey: "chat_User") + " " + PTLanguage.share.text(forKey: "about_Setting")
        } else {
            self.zx_navTitle = PTLanguage.share.text(forKey: "about_Setting")
        }
        self.view.backgroundColor = .gobalScrollerBackgroundColor
        
        // Do any additional setup after loading the view.
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        
        self.showDetail()
        
        SwiftSpinner.useContainerView(AppDelegate.appDelegate()!.window)
        SwiftSpinner.setTitleFont(UIFont.appfont(size: 24))
        
        self.pt_observerLanguage {
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    self.zx_navTitle = PTLanguage.share.text(forKey: "about_Setting")
                    self.showDetail()
                }
            }
        }
    }
    
    func showDetail() {
        mSections.removeAll()

        self.aboutModels().enumerated().forEach { (index,value) in
            var rows = [PTRows]()
            value.models.enumerated().forEach { (subIndex,subValue) in
                if subValue.name == PTLanguage.share.text(forKey: "about_AI_smart") {
                    let row_List = PTRows.init(title: subValue.name, placeholder: subValue.content,cls: PTAISmartCell.self, ID: PTAISmartCell.ID, dataModel: subValue)
                    rows.append(row_List)
                } else if subValue.name == PTLanguage.share.text(forKey: "MoDi") || subValue.name == PTLanguage.share.text(forKey: "V1.4") || subValue.name == PTLanguage.share.text(forKey: "V1.5") || subValue.name == PTLanguage.share.text(forKey: "TEST") {
                    let row_List = PTRows.init(cls: PTStableDiffusionModelCell.self, ID: PTStableDiffusionModelCell.ID, dataModel: subValue)
                    rows.append(row_List)
                } else {
                    let row_List = PTRows.init(title: subValue.name, placeholder: subValue.content,cls: PTFusionCell.self, ID: PTFusionCell.ID, dataModel: subValue)
                    rows.append(row_List)
                }
            }
            
            var headerHeight:CGFloat = 0
            if Gobal_device_info.isPad {
                headerHeight = 44
            } else {
                headerHeight = CGFloat.ScaleW(w: 44)
            }
            if value.name == PTLanguage.share.text(forKey: "about_Main_Other") {
                let cellSection = PTSection.init(headerTitle:value.name,headerCls:PTSettingHeader.self,headerID: PTSettingHeader.ID,footerCls:PTSettingFooter.self,footerID:PTSettingFooter.ID,footerHeight:CGFloat.kTabbarHeight_Total,headerHeight: headerHeight,rows: rows)
                mSections.append(cellSection)
            } else {
                let cellSection = PTSection.init(headerTitle:value.name,headerCls:PTSettingHeader.self,headerID: PTSettingHeader.ID,headerHeight: headerHeight,rows: rows)
                mSections.append(cellSection)
            }
        }
        
        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }
    
    //MARK: 進入相冊
    func enterPhotos(string:String) {
        Task {
            do {
                let object:UIImage = try await PTImagePicker.openAlbum()
                await MainActor.run{
                    switch string {
                    case PTLanguage.share.text(forKey: "about_User_icon"):
                        AppDelegate.appDelegate()!.appConfig.userIcon = object.pngData()!
                    case PTLanguage.share.text(forKey: "draw_Reference"):
                        AppDelegate.appDelegate()!.appConfig.drawRefrence = object.pngData()!
                    default:break
                    }
                    self.showDetail()
                    PTNSLogConsole(object)
                }
            } catch let pickerError as PTImagePicker.PickerError {
                pickerError.outPutLog()
            }
        }
    }
}

extension PTSettingListViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionHeader {
            if itemSec.headerID == PTSettingHeader.ID {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.headerID!, for: indexPath) as! PTSettingHeader
                header.titleLabel.text = itemSec.headerTitle
                return header
            }
            return UICollectionReusableView()
        } else if kind == UICollectionView.elementKindSectionFooter {
            if itemSec.footerID == PTSettingFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTSettingFooter
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.dataContent.backgroundColor = .gobalCellBackgroundColor
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.topLineView.isHidden = true
            if itemRow.title == SettingCloudString {
                cell.dataContent.valueSwitch.isOn = AppDelegate.appDelegate()!.appConfig.cloudSwitch
                cell.dataContent.valueSwitch.addSwitchAction { sender in
                    AppDelegate.appDelegate()?.appConfig.mobileDataSavePlaceChange(value: sender.isOn)
                }
            }
            else if itemRow.title == PTLanguage.share.text(forKey: "about_Use_custom_domain_switch") {
                cell.dataContent.valueSwitch.isOn = AppDelegate.appDelegate()!.appConfig.useCustomDomain
                cell.dataContent.valueSwitch.addSwitchAction { sender in
                    AppDelegate.appDelegate()?.appConfig.useCustomDomain = sender.isOn
                }
            }
            
            if itemSec.rows.count == 1 {
                PTGCDManager.gcdMain {
                    cell.dataContent.viewCornerRectCorner(cornerRadii:5,corner:.allCorners)
                }
            } else {
                if indexPath.row == 0 {
                    PTGCDManager.gcdMain {
                        cell.dataContent.viewCornerRectCorner(cornerRadii: 5,corner:[.topLeft,.topRight])
                    }
                } else if indexPath.row == (itemSec.rows.count - 1) {
                    PTGCDManager.gcdMain {
                        cell.dataContent.viewCornerRectCorner(cornerRadii: 5,corner:[.bottomLeft,.bottomRight])
                    }
                }
            }
            return cell
        } else if itemRow.ID == PTAISmartCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTAISmartCell
            cell.contentView.backgroundColor = .gobalCellBackgroundColor
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            cell.aiSlider.addSliderAction { sender in
                var realSmart = (1 - sender.value)
                if realSmart <= 0 {
                    realSmart = 1
                }
                AppDelegate.appDelegate()!.appConfig.aiSmart = Double(realSmart)
            }
            return cell
        } else if itemRow.ID == PTStableDiffusionModelCell.ID {
            let cellModel = self.downloadInfo[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTStableDiffusionModelCell
            cell.contentView.backgroundColor = .gobalCellBackgroundColor
            cell.cellModel = cellModel
            cell.lineView.isHidden = (itemSec.rows.count - 1) == indexPath.row
            cell.downloadFinishBlock = {
                #if DEBUG
                self.downloadInfo[indexPath.row]!.loadFinish = indexPath.row == (self.downloadInfo.count - 1) ? false : true
                #else
                self.downloadInfo[indexPath.row]!.loadFinish = true
                #endif
                
                AppDelegate.appDelegate()!.appConfig.downloadInfomation = self.downloadInfo.kj.JSONObjectArray()
            }
            if itemSec.rows.count == 1 {
                PTGCDManager.gcdMain {
                    cell.contentView.viewCornerRectCorner(cornerRadii:5,corner:.allCorners)
                }
            } else {
                if indexPath.row == 0 {
                    PTGCDManager.gcdMain {
                        cell.contentView.viewCornerRectCorner(cornerRadii: 5,corner:[.topLeft,.topRight])
                    }
                } else if indexPath.row == (itemSec.rows.count - 1) {
                    PTGCDManager.gcdMain {
                        cell.contentView.viewCornerRectCorner(cornerRadii: 5,corner:[.bottomLeft,.bottomRight])
                    }
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.title == PTLanguage.share.text(forKey: "about_Color") {
            let vc = PTColorSettingViewController(user: self.user)
            let nav = PTNavController(rootViewController: vc)
            if Gobal_device_info.isPad {
                nav.modalPresentationStyle = .formSheet
                nav.preferredContentSize = CGSize(width: 400, height: CGFloat.kSCREEN_HEIGHT)
                self.splitViewController?.present(nav, animated: true)
            } else {
                nav.modalPresentationStyle = .fullScreen
                self.navigationController?.present(nav, animated: true)
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_SavedChat") {
            let vc = PTSaveChatViewController()
            self.navigationController?.pushViewController(vc)
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_DeleteAllChat") {
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "chat_Delete_all_chat"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                
                let arr = AppDelegate.appDelegate()!.appConfig.tagDataArr()
                for (index,_) in arr.enumerated() {
                    arr[index]!.historyModel = [PTChatModel]()
                }
                AppDelegate.appDelegate()!.appConfig.setChatData = arr.kj.JSONObjectArray()
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
                if self.cleanChatListBlock != nil {
                    self.cleanChatListBlock!()
                }
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_APIAIType") {
            self.AIModelPicker.show()
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_APIAIToken") {
            let textKey = PTLanguage.share.text(forKey: "alert_Input_token")
            let apiToken = AppDelegate.appDelegate()!.appConfig.apiToken
            UIAlertController.base_textfiele_alertVC(title:textKey,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey], textFieldTexts: [apiToken], keyboardType: [.default],textFieldDelegate: self) { result in
                let newToken:String? = result[textKey]!
                if (newToken ?? "").stringIsEmpty() || !(newToken ?? "").nsString.contains("sk-") {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Token_error"))
                } else {
                    AppDelegate.appDelegate()!.appConfig.apiToken = newToken!
                }
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Use_custom_domain_address") {
            let textKey = PTLanguage.share.text(forKey: "alert_Enter_domain")
            let domain = AppDelegate.appDelegate()!.appConfig.customDomain
            UIAlertController.base_textfiele_alertVC(title:textKey,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey], textFieldTexts: [domain], keyboardType: [.default],textFieldDelegate: self) { result in
                let newDomain:String? = result[textKey]!
                if (newDomain ?? "").stringIsEmpty() || !(newDomain ?? "").isURL() {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Domain_error"))
                } else {
                    AppDelegate.appDelegate()!.appConfig.customDomain = newDomain!
                    self.showDetail()
                }
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_GetAPIAIToken") {
            let url = URL(string: getApiUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if itemRow.title == SettingGithub {
            let url = URL(string: myGithubUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Forum") {
            let url = URL(string: projectGithubUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Share") {
            let title = kAppName!
            let content = "Look at me!!!!!!!"
            let shareLink = projectGithubUrl
            let url = URL(string: shareLink)!
            let shareItem = PTShareItem(title: title, content: content, url: url)
            let activityViewController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
            if Gobal_device_info.isPad {
                let nav = PTNavController(rootViewController: activityViewController)
                nav.modalPresentationStyle = .formSheet
                self.present(nav, animated: true, completion: nil)
            } else {
                self.present(activityViewController, animated: true, completion: nil)
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Rate") {
            PTAppStoreFunction.rateApp(appid: AppAppStoreID)
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Main_Speech") {
            self.languagePicker.title = PTLanguage.share.text(forKey: "about_Main_Speech")
            self.languagePicker.selectValue = AppDelegate.appDelegate()!.appConfig.language
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()!.appConfig.languagePickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                AppDelegate.appDelegate()!.appConfig.language = OSSVoiceEnum.allCases[route!.index].rawValue
                self.showDetail()
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Language") {
            self.languagePicker.title = PTLanguage.share.text(forKey: "about_Language")
            self.languagePicker.selectValue = self.currentSelectedLanguage
            self.languagePicker.dataSourceArr = LanguageKey.allNames
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                self.currentSelectedLanguage = LanguageKey.allValues[route!.index].desc
                PTLanguage.share.language = LanguageKey.allValues[route!.index].rawValue
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Main_Theme") {
            let vc = PTDarkModeControl()
            self.navigationController?.pushViewController(vc)
            vc.themeSetBlock = {
                self.showDetail()
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_User_icon") {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { blockStatus in
                    if blockStatus == .authorized {
                        PTGCDManager.gcdMain {
                            self.enterPhotos(string: itemRow.title)
                        }
                    }
                }
            } else if status == .authorized {
                self.enterPhotos(string: itemRow.title)
            } else if status == .denied {
                let messageString = String(format: PTLanguage.share.text(forKey: "alert_Go_to_photo_setting"), kAppName!)
                PTBaseViewController.gobal_drop(title: messageString)
            } else {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_No_photo_library"))
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_User_name") {
            PTGCDManager.gcdAfter(time: 0.5) {
                let title = PTLanguage.share.text(forKey: "alert_Name_edit_title")
                let placeHolder = PTLanguage.share.text(forKey: "alert_Name_edit_placeholder")
                UIAlertController.base_textfiele_alertVC(title:title,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [placeHolder], textFieldTexts: [AppDelegate.appDelegate()!.appConfig.userName], keyboardType: [.default],textFieldDelegate: self) { result in
                    let userName:String? = result[placeHolder]!
                    if !(userName ?? "").stringIsEmpty() {
                        AppDelegate.appDelegate()?.appConfig.userName = userName!
                        PTChatData.share.user = PTChatUser(senderId: "000000", displayName: AppDelegate.appDelegate()!.appConfig.userName)
                        self.showDetail()
                        if self.cleanChatListBlock != nil {
                            self.cleanChatListBlock!()
                        }
                    } else {
                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                    }
                }
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_AI_name") {
            PTGCDManager.gcdAfter(time: 0.5) {
                let title = PTLanguage.share.text(forKey: "alert_AI_name_edit")
                UIAlertController.base_textfiele_alertVC(title:title,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [title], textFieldTexts: [AppDelegate.appDelegate()!.appConfig.aiName], keyboardType: [.default],textFieldDelegate: self) { result in
                    let userName:String? = result[title]!
                    if !(userName ?? "").stringIsEmpty() {
                        AppDelegate.appDelegate()?.appConfig.aiName = userName!
                        PTChatData.share.bot = PTChatUser(senderId: "000001", displayName: AppDelegate.appDelegate()!.appConfig.aiName)
                        self.showDetail()
                        if self.cleanChatListBlock != nil {
                            self.cleanChatListBlock!()
                        }
                    } else {
                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                    }
                }
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Delete_all_voice_file") {
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "chat_Delete_all_voice_file"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                let speechKit = OSSSpeech.shared
                speechKit.delegate = self
                speechKit.deleteVoiceFolderItem(url: nil)
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Draw_image_size") {
            let imageSize = AppDelegate.appDelegate()!.appConfig.aiDrawSize
            self.languagePicker.title = PTLanguage.share.text(forKey: "about_Language")
            self.languagePicker.selectValue = "\(String(format: "%.0f", imageSize.width))x\(String(format: "%.0f", imageSize.height))"
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()?.appConfig.imageSizeArray
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                switch AppDelegate.appDelegate()?.appConfig.imageSizeArray[route!.index] {
                case PTOpenAIImageSize.size1024.rawValue:
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = CGSize(width: 1024, height: 1024)
                case PTOpenAIImageSize.size512.rawValue:
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = CGSize(width: 512, height: 512)
                default:
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = CGSize(width: 256, height: 256)
                }
                self.showDetail()
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "chat_Get_image_count") {
            let imageCount = AppDelegate.appDelegate()!.appConfig.getImageCount
            self.languagePicker.title = PTLanguage.share.text(forKey: "chat_Get_image_count")
            self.languagePicker.selectValue = "\(imageCount)"
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()?.appConfig.getImageCountPickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                AppDelegate.appDelegate()?.appConfig.getImageCount = (AppDelegate.appDelegate()?.appConfig.getImageCountPickerData[route!.index].int)!
                self.showDetail()
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "draw_Reference") {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { blockStatus in
                    if blockStatus == .authorized {
                        PTGCDManager.gcdMain {
                            self.enterPhotos(string: itemRow.title)
                        }
                    }
                }
            } else if status == .authorized {
                self.enterPhotos(string: itemRow.title)
            } else if status == .denied {
                let messageString = String(format: PTLanguage.share.text(forKey: "alert_Go_to_photo_setting"), kAppName!)
                PTBaseViewController.gobal_drop(title: messageString)
            } else {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_No_photo_library"))
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "setting_Reset") {
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_Reset_all_setting"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                PTGCDManager.gcdMain {
                    SwiftSpinner.show("正在重置設定")
                    AppDelegate.appDelegate()!.appConfig.mobileDataReset(delegate:self) {
                        SwiftSpinner.show("清空聊天記錄中")
                    } resetChat: {
                        SwiftSpinner.show("刪除圖片緩存中")
                    } resetVoiceFile: {
                        SwiftSpinner.show("刪除語音緩存中")
                    } resetImage: {
                        SwiftSpinner.show("完成!")

                        PTGCDManager.gcdAfter(time: 1) {
                            SwiftSpinner.hide() {
                                self.showDetail()
                                if self.cleanChatListBlock != nil {
                                    self.cleanChatListBlock!()
                                }
                            }
                        }
                    }
                }
            }
        } else if itemRow.title == PTLanguage.share.text(forKey: "about_Help") {
            let vc = PTHelpViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PTSettingListViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

extension PTSettingListViewController:OSSSpeechDelegate {
    func voiceFilePathTranscription(withText text: String) {
        
    }
    
    func deleteVoiceFile(withFinish finish: Bool, withError error: Error?) {
        if finish {
            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
        } else {
            PTBaseViewController.gobal_drop(title: error!.localizedDescription)
        }
    }
    
    func didFinishListening(withText text: String) {
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        
    }
    
    func didFailToCommenceSpeechRecording() {
        
    }
    
    func didCompleteTranslation(withText text: String) {
        
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        
    }
    
    func didFinishListening(withAudioFileURL url: URL, withText text: String) {
    }
}

extension PTSettingListViewController {
    override public func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        let layout = PTChatPanelLayout()
        layout.viewHeight = CGFloat.kTabbarSaveAreaHeight + CGFloat.ScaleW(w: 44) + CGFloat.ScaleW(w: 10) + CGFloat.ScaleW(w: 44) * 3 + CGFloat.ScaleW(w: 34) + CGFloat.ScaleW(w: 10) + CGFloat.ScaleW(w: 24) + CGFloat.ScaleW(w: 13)
        return layout
    }
}

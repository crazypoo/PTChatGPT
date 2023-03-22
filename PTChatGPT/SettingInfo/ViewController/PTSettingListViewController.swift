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

extension String
{
    //MARK: iCloud
    static let cloudString = "iCloud"
    //MARK: 主題
    static let colorString = PTLanguage.share.text(forKey: "about_Color")
    static let userIcon = PTLanguage.share.text(forKey: "about_User_icon")
    static let languageString = PTLanguage.share.text(forKey: "about_Language")
    static let themeString = PTLanguage.share.text(forKey: "about_Main_Theme")
    //MARK: 聊天相關
    static let savedChat = PTLanguage.share.text(forKey: "about_SavedChat")
    static let deleteAllChat = PTLanguage.share.text(forKey: "about_DeleteAllChat")
    static let deleteAllVoiceFile = PTLanguage.share.text(forKey: "about_Delete_all_voice_file")
    //MARK: Speech
    static let speech = PTLanguage.share.text(forKey: "about_Main_Speech")
    //MARK: API
    static let apiAIType = PTLanguage.share.text(forKey: "about_APIAIType")
    static let apiAIToken = PTLanguage.share.text(forKey: "about_APIAIToken")
    static let aiSmart = PTLanguage.share.text(forKey: "about_AI_smart")
    static let getAPIAIToken = PTLanguage.share.text(forKey: "about_GetAPIAIToken")
    static let drawImageSize = PTLanguage.share.text(forKey: "about_Draw_image_size")
    static let getImageCount = PTLanguage.share.text(forKey: "chat_Get_image_count")
    //MARK: Other
    static let github = PTLanguage.share.text(forKey: "Github")
    static let forum = PTLanguage.share.text(forKey: "about_Forum")
    static let rate = PTLanguage.share.text(forKey: "about_Rate")
    static let share = PTLanguage.share.text(forKey: "about_Share")
}

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

    var currentChatModel:PTSegHistoryModel?
    
    var cleanChatListBlock:(()->Void)?
    
    lazy var pickerData : [String] = {
        return ["中文(简体)/中文(簡體)/Chinese(Simplified)/Chine(Simplificado)","中文(繁体)/中文(簡體)/Chinese(Hong Kong)/Chino(Hong Kong)","英语/英語/English/Inglés","西班牙语/西班牙語/Spanish/Español"]
    }()
    
    lazy var languageFileName:[String] = {
        return ["zh-Hans","zh-HK","en","es"]
    }()
    
    lazy var currentSelectedLanguage = PTLanguage.share.language

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
        }
        picker.pickerStyle = PTAppConfig.gobal_BRPickerStyle()
        picker.title = PTLanguage.share.text(forKey: "about_APIAIType")
        return picker
    }()
        
    lazy var aboutModels : [PTSettingModels] = {
        
        let disclosureIndicatorImageName = UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal)
        
        let cloudMain = PTSettingModels()
        cloudMain.name = "iCloud"
        
        let cloud = PTFusionCellModel()
        cloud.name = .cloudString
        cloud.haveSwitch = true
        cloud.nameColor = .gobalTextColor

        cloudMain.models = [cloud]

        let themeMain = PTSettingModels()
        themeMain.name = PTLanguage.share.text(forKey: "about_Main_Theme")
        
        //MARK: 主題
        let color = PTFusionCellModel()
        color.name = .colorString
        color.haveDisclosureIndicator = true
        color.nameColor = .gobalTextColor
        color.disclosureIndicatorImage = disclosureIndicatorImageName

        let language = PTFusionCellModel()
        language.name = .languageString
        language.haveDisclosureIndicator = true
        language.nameColor = .gobalTextColor
        language.disclosureIndicatorImage = disclosureIndicatorImageName

        let theme = PTFusionCellModel()
        theme.name = .themeString
        theme.haveDisclosureIndicator = true
        theme.nameColor = .gobalTextColor
        theme.disclosureIndicatorImage = disclosureIndicatorImageName
        
        let userIcon = PTFusionCellModel()
        userIcon.name = .userIcon
        userIcon.haveDisclosureIndicator = true
        userIcon.nameColor = .gobalTextColor
        userIcon.disclosureIndicatorImage = disclosureIndicatorImageName

        if self.user.senderId == PTChatData.share.bot.senderId {
            themeMain.models = [color]
        } else if self.user.senderId == PTChatData.share.user.senderId {
            themeMain.models = [color,userIcon]
        } else {
            themeMain.models = [color,userIcon,language,theme]
        }
        
        //MARK: Speech
        let speechMain = PTSettingModels()
        speechMain.name = PTLanguage.share.text(forKey: "about_Main_Speech")

        let speechLanguage = PTFusionCellModel()
        speechLanguage.name = .speech
        speechLanguage.haveDisclosureIndicator = true
        speechLanguage.nameColor = .gobalTextColor
        speechLanguage.disclosureIndicatorImage = disclosureIndicatorImageName

        speechMain.models = [speechLanguage]

        //MARK: Chat
        let chatMain = PTSettingModels()
        chatMain.name = "Chat"

        let savedMessage = PTFusionCellModel()
        savedMessage.name = .savedChat
        savedMessage.haveDisclosureIndicator = true
        savedMessage.nameColor = .gobalTextColor
        savedMessage.disclosureIndicatorImage = disclosureIndicatorImageName

        let deleteAllChat = PTFusionCellModel()
        deleteAllChat.name = .deleteAllChat
        deleteAllChat.haveDisclosureIndicator = true
        deleteAllChat.nameColor = .gobalTextColor
        deleteAllChat.disclosureIndicatorImage = disclosureIndicatorImageName

        let deleteAllVoiceFile = PTFusionCellModel()
        deleteAllVoiceFile.name = .deleteAllVoiceFile
        deleteAllVoiceFile.haveDisclosureIndicator = true
        deleteAllVoiceFile.nameColor = .gobalTextColor
        deleteAllVoiceFile.disclosureIndicatorImage = disclosureIndicatorImageName

        chatMain.models = [savedMessage,deleteAllChat,deleteAllVoiceFile]
        
        let apiMain = PTSettingModels()
        apiMain.name = "API"

        //MARK: API
        let aiType = PTFusionCellModel()
        aiType.name = .apiAIType
        aiType.haveDisclosureIndicator = true
        aiType.nameColor = .gobalTextColor
        aiType.disclosureIndicatorImage = disclosureIndicatorImageName
        
        let aiSmart = PTFusionCellModel()
        aiSmart.name = .aiSmart
        aiSmart.nameColor = .gobalTextColor
        
        let drawSize = PTFusionCellModel()
        drawSize.name = .drawImageSize
        drawSize.haveDisclosureIndicator = true
        drawSize.nameColor = .gobalTextColor
        drawSize.disclosureIndicatorImage = disclosureIndicatorImageName
        
        let imageCount = PTFusionCellModel()
        imageCount.name = .getImageCount
        imageCount.haveDisclosureIndicator = true
        imageCount.nameColor = .gobalTextColor
        imageCount.disclosureIndicatorImage = disclosureIndicatorImageName

        let aiToken = PTFusionCellModel()
        aiToken.name = .apiAIToken
        aiToken.haveDisclosureIndicator = true
        aiToken.nameColor = .gobalTextColor
        aiToken.disclosureIndicatorImage = disclosureIndicatorImageName

        let getApiToken = PTFusionCellModel()
        getApiToken.name = .getAPIAIToken
        getApiToken.haveDisclosureIndicator = true
        getApiToken.nameColor = .gobalTextColor
        getApiToken.disclosureIndicatorImage = disclosureIndicatorImageName

        if self.user.senderId == PTChatData.share.bot.senderId {
            apiMain.models = [aiType,aiSmart,drawSize,imageCount,aiToken]
        } else {
            apiMain.models = [aiType,aiSmart,drawSize,imageCount,aiToken,getApiToken]
        }
        
        let otherMain = PTSettingModels()
        otherMain.name = PTLanguage.share.text(forKey: "about_Main_Other")

        //MARK: Other
        let github = PTFusionCellModel()
        github.name = .github
        github.haveDisclosureIndicator = true
        github.nameColor = .gobalTextColor
        github.disclosureIndicatorImage = disclosureIndicatorImageName

        let forum = PTFusionCellModel()
        forum.name = .forum
        forum.haveDisclosureIndicator = true
        forum.nameColor = .gobalTextColor
        forum.disclosureIndicatorImage = disclosureIndicatorImageName

        let rate = PTFusionCellModel()
        rate.name = .rate
        rate.haveDisclosureIndicator = true
        rate.nameColor = .gobalTextColor
        rate.disclosureIndicatorImage = disclosureIndicatorImageName

        let share = PTFusionCellModel()
        share.name = .share
        share.haveDisclosureIndicator = true
        share.nameColor = .gobalTextColor
        share.disclosureIndicatorImage = disclosureIndicatorImageName
        
        otherMain.models = [github,forum,rate,share]
        
        if self.user.senderId == PTChatData.share.bot.senderId {
            return [themeMain,apiMain]
        } else if self.user.senderId == PTChatData.share.user.senderId {
            return [themeMain,speechMain]
        } else {
            return [cloudMain,themeMain,speechMain,chatMain,apiMain,otherMain]
        }
    }()

    var mSections = [PTSection]()
    func comboLayout()->UICollectionViewCompositionalLayout
    {
        let layout = UICollectionViewCompositionalLayout.init { section, environment in
            self.generateSection(section: section)
        }
        layout.register(PTBaseDecorationView_Corner.self, forDecorationViewOfKind: "background")
        layout.register(PTBaseDecorationView.self, forDecorationViewOfKind: "background_no")
        return layout
    }
    
    func generateSection(section:NSInteger)->NSCollectionLayoutSection
    {
        let sectionModel = mSections[section]

        var group : NSCollectionLayoutGroup
        let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
        
        var bannerGroupSize : NSCollectionLayoutSize
        var customers = [NSCollectionLayoutGroupCustomItem]()
        var groupH:CGFloat = 0
        sectionModel.rows.enumerated().forEach { (index,model) in
            var cellHeight:CGFloat = CGFloat.ScaleW(w: 44)
            if (model.dataModel as! PTFusionCellModel).name == .aiSmart
            {
                cellHeight = CGFloat.ScaleW(w: 98)
            }
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
            customers.append(customItem)
            groupH += cellHeight
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
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

        let headerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.headerHeight ?? CGFloat.leastNormalMagnitude))
        let footerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.footerHeight ?? CGFloat.leastNormalMagnitude))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topTrailing)
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing)
        if sectionModel.headerTitle == PTLanguage.share.text(forKey: "about_Main_Other")
        {
            laySection.boundarySupplementaryItems = [headerItem,footerItem]
        }
        else
        {
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

        if self.user.senderId == PTChatData.share.bot.senderId
        {
            self.zx_navTitle = "ZolaAi " + PTLanguage.share.text(forKey: "about_Setting")
        }
        else if self.user.senderId == PTChatData.share.user.senderId
        {
            self.zx_navTitle = PTLanguage.share.text(forKey: "chat_User") + " " + PTLanguage.share.text(forKey: "about_Setting")
        }
        else
        {
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
    }
    
    func showDetail()
    {
        mSections.removeAll()

        self.aboutModels.enumerated().forEach { (index,value) in
            var rows = [PTRows]()
            value.models.enumerated().forEach { (subIndex,subValue) in
                
                if subValue.name == .aiSmart
                {
                    let row_List = PTRows.init(title: subValue.name, placeholder: subValue.content,cls: PTAISmartCell.self, ID: PTAISmartCell.ID, dataModel: subValue)
                    rows.append(row_List)
                }
                else
                {
                    let row_List = PTRows.init(title: subValue.name, placeholder: subValue.content,cls: PTFusionCell.self, ID: PTFusionCell.ID, dataModel: subValue)
                    rows.append(row_List)
                }
            }
            
            if value.name == PTLanguage.share.text(forKey: "about_Main_Other")
            {
                let cellSection = PTSection.init(headerTitle:value.name,headerCls:PTSettingHeader.self,headerID: PTSettingHeader.ID,footerCls:PTSettingFooter.self,footerID:PTSettingFooter.ID,footerHeight:CGFloat.kTabbarHeight_Total,headerHeight: CGFloat.ScaleW(w: 44),rows: rows)
                mSections.append(cellSection)
            }
            else
            {
                let cellSection = PTSection.init(headerTitle:value.name,headerCls:PTSettingHeader.self,headerID: PTSettingHeader.ID,headerHeight: CGFloat.ScaleW(w: 44),rows: rows)
                mSections.append(cellSection)
            }
        }
        
        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }
    
    //MARK: 進入相冊
    func enterPhotos()
    {
        PTGCDManager.gcdAfter(time: 0.1) {
            if #available(iOS 14.0, *)
            {
                Task{
                    do{
                        let object:UIImage = try await PTImagePicker.openAlbum()
                        await MainActor.run{
                            AppDelegate.appDelegate()!.appConfig.userIcon = object.pngData()!
                            PTNSLogConsole(object)
                        }
                    }
                    catch let pickerError as PTImagePicker.PickerError
                    {
                        pickerError.outPutLog()
                    }
                }
            }
            else
            {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                imagePicker.modalPresentationStyle = .fullScreen
                self.present(imagePicker, animated: true)
            }
        }
    }
}

extension PTSettingListViewController:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionHeader
        {
            if itemSec.headerID == PTSettingHeader.ID
            {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.headerID!, for: indexPath) as! PTSettingHeader
                header.titleLabel.text = itemSec.headerTitle
                return header
            }
            return UICollectionReusableView()
        }
        else if kind == UICollectionView.elementKindSectionFooter
        {
            if itemSec.footerID == PTSettingFooter.ID
            {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTSettingFooter
                return footer
            }
            return UICollectionReusableView()
        }
        else
        {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTFusionCell.ID
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.dataContent.backgroundColor = .gobalCellBackgroundColor
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.topLineView.isHidden = true
            if itemRow.title == .cloudString
            {
                cell.dataContent.valueSwitch.onTintColor = UIColor.orange
                cell.dataContent.valueSwitch.isOn = AppDelegate.appDelegate()!.appConfig.cloudSwitch
                cell.dataContent.valueSwitch.addSwitchAction { sender in
                    AppDelegate.appDelegate()?.appConfig.cloudSwitch = sender.isOn
                    AppDelegate.appDelegate()?.appConfig.mobileDataSavePlaceChange()
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
        }
        else if itemRow.ID == PTAISmartCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTAISmartCell
            cell.contentView.backgroundColor = .gobalCellBackgroundColor
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            cell.aiSlider.addSliderAction { sender in
                let realSmart = (1 - sender.value)
                AppDelegate.appDelegate()!.appConfig.aiSmart = Double(realSmart)
            }
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.title == .colorString
        {
            let vc = PTColorSettingViewController(user: self.user)
            let nav = PTNavController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true)
        }
        else if itemRow.title == .savedChat
        {
            let vc = PTSaveChatViewController()
            self.navigationController?.pushViewController(vc)
        }
        else if itemRow.title == .deleteAllChat
        {
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "chat_Delete_all_chat"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                
                var arr = [PTSegHistoryModel]()
                if let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory {
                    let dataArr = dataString.components(separatedBy: kSeparatorSeg)
                    dataArr.enumerated().forEach { index,value in
                        let model = PTSegHistoryModel.deserialize(from: value)
                        arr.append(model!)
                    }
                    for (index,_) in arr.enumerated() {
                        arr[index].historyModel = [PTChatModel]()
                    }
                    
                    var newJsonArr = [String]()
                    arr.enumerated().forEach { index,value in
                        newJsonArr.append(value.toJSON()!.toJSON()!)
                    }
                    AppDelegate.appDelegate()!.appConfig.segChatHistory = newJsonArr.joined(separator: kSeparatorSeg)
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
                    if self.cleanChatListBlock != nil {
                        self.cleanChatListBlock!()
                    }
                }
            }
        }
        else if itemRow.title == .apiAIType
        {
            self.AIModelPicker.show()
        }
        else if itemRow.title == .apiAIToken
        {
            let textKey = PTLanguage.share.text(forKey: "alert_Input_token")
            let apiToken = AppDelegate.appDelegate()!.appConfig.apiToken
            UIAlertController.base_textfiele_alertVC(title:textKey,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey], textFieldTexts: [apiToken], keyboardType: [.default],textFieldDelegate: self) { result in
                let newToken:String? = result[textKey]!
                if (newToken ?? "").stringIsEmpty() || !(newToken ?? "").nsString.contains("sk-")
                {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Token_error"))
                }
                else
                {
                    AppDelegate.appDelegate()!.appConfig.apiToken = newToken!
                }
            }
        }
        else if itemRow.title == .getAPIAIToken
        {
            let url = URL(string: getApiUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else if itemRow.title == .github
        {
            let url = URL(string: myGithubUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else if itemRow.title == .forum
        {
            let url = URL(string: projectGithubUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else if itemRow.title == .share
        {
            let title = kAppName!
            let content = "Look at me!!!!!!!"
            let shareLink = projectGithubUrl
            let url = URL(string: shareLink)!
            let shareItem = PTShareItem(title: title, content: content, url: url)
            let activityViewController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
        else if itemRow.title == .rate
        {
            PTAppStoreFunction.rateApp(appid: "6446197340")
        }
        else if itemRow.title == .speech
        {
            self.languagePicker.title = PTLanguage.share.text(forKey: "about_Main_Speech")
            self.languagePicker.selectValue = AppDelegate.appDelegate()!.appConfig.language
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()!.appConfig.languagePickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                AppDelegate.appDelegate()!.appConfig.language = OSSVoiceEnum.allCases[route!.index].rawValue
            }
        }
        else if itemRow.title == .languageString
        {
            self.languagePicker.title = PTLanguage.share.text(forKey: "about_Language")
            self.languagePicker.selectValue = self.currentSelectedLanguage
            self.languagePicker.dataSourceArr = self.pickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                self.currentSelectedLanguage = self.languageFileName[route!.index]
                PTLanguage.share.language = self.currentSelectedLanguage
                self.showDetail()
            }
        }
        else if itemRow.title == .themeString
        {
            let vc = PTDarkModeControl()
            self.navigationController?.pushViewController(vc)
        }
        else if itemRow.title == .userIcon
        {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined
            {
                PHPhotoLibrary.requestAuthorization { blockStatus in
                    if blockStatus == .authorized
                    {
                        PTGCDManager.gcdMain {
                            self.enterPhotos()
                        }
                    }
                }
            }
            else if status == .authorized
            {
                self.enterPhotos()
            }
            else if status == .denied
            {
                let messageString = String(format: PTLanguage.share.text(forKey: "alert_Go_to_photo_setting"), kAppName!)
                PTBaseViewController.gobal_drop(title: messageString)
            }
            else
            {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_No_photo_library"))
            }
        }
        else if itemRow.title == .deleteAllVoiceFile
        {
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "chat_Delete_all_voice_file"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                let speechKit = OSSSpeech.shared
                speechKit.delegate = self
                speechKit.deleteVoiceFolderItem(url: nil)
            }
        } else if itemRow.title == .drawImageSize {
            let imageSize = AppDelegate.appDelegate()!.appConfig.aiDrawSize
            self.languagePicker.title = PTLanguage.share.text(forKey: "about_Language")
            self.languagePicker.selectValue = "\(String(format: "%.0f", imageSize.width))x\(String(format: "%.0f", imageSize.height))"
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()?.appConfig.imageSizeArray
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                switch AppDelegate.appDelegate()?.appConfig.imageSizeArray[route!.index] {
                case "1024x1024":
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = CGSize(width: 1024, height: 1024)
                case "512x512":
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = CGSize(width: 512, height: 512)
                default:
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = CGSize(width: 256, height: 256)
                }
            }
        } else if itemRow.title == .getImageCount {
            let imageCount = AppDelegate.appDelegate()!.appConfig.getImageCount
            self.languagePicker.title = .getImageCount
            self.languagePicker.selectValue = "\(imageCount)"
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()?.appConfig.getImageCountPickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                AppDelegate.appDelegate()?.appConfig.getImageCount = (AppDelegate.appDelegate()?.appConfig.getImageCountPickerData[route!.index].int)!
            }
        }
    }
}

extension PTSettingListViewController:UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("123123123123123")
    }
}

extension PTSettingListViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.returnFrontVC()
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageData = image.pngData()
        AppDelegate.appDelegate()!.appConfig.userIcon = imageData!
        PTNSLogConsole(image)
    }
}

extension PTSettingListViewController:OSSSpeechDelegate
{
    func voiceFilePathTranscription(withText text: String) {
        
    }
    
    func deleteVoiceFile(withFinish finish: Bool, withError error: Error?) {
        if finish
        {
            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
        }
        else
        {
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

extension PTSettingListViewController
{
    override public func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        let layout = PTChatPanelLayout()
        layout.viewHeight = CGFloat.kTabbarSaveAreaHeight + CGFloat.ScaleW(w: 44) + CGFloat.ScaleW(w: 10) + CGFloat.ScaleW(w: 44) * 3 + CGFloat.ScaleW(w: 34) + CGFloat.ScaleW(w: 10) + CGFloat.ScaleW(w: 24) + CGFloat.ScaleW(w: 13)
        return layout
    }
}

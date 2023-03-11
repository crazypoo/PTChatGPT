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

fileprivate extension String
{
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
    //MARK: Other
    static let github = PTLanguage.share.text(forKey: "Github")
    static let forum = PTLanguage.share.text(forKey: "about_Forum")
    static let rate = PTLanguage.share.text(forKey: "about_Rate")
    static let share = PTLanguage.share.text(forKey: "about_Share")
    static let version = PTLanguage.share.text(forKey: "about_Version")
}

class PTSettingListViewController: PTChatBaseViewController {

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
        AppDelegate.appDelegate()!.appConfig.getAiModelPickerDate(currentAi: AppDelegate.appDelegate()!.appConfig.aiModelType) { result, selectIndex in
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
    
    var aboutModels : [PTSettingModels] = {
        
        let disclosureIndicatorImageName = UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal)
        
        let themeMain = PTSettingModels()
        themeMain.name = PTLanguage.share.text(forKey: "about_Main_Theme")
        
        //MARK: 主題
        let color = PTFunctionCellModel()
        color.name = .colorString
        color.haveDisclosureIndicator = true
        color.nameColor = .gobalTextColor
        color.disclosureIndicatorImageName = disclosureIndicatorImageName

        let language = PTFunctionCellModel()
        language.name = .languageString
        language.haveDisclosureIndicator = true
        language.nameColor = .gobalTextColor
        language.disclosureIndicatorImageName = disclosureIndicatorImageName

        let theme = PTFunctionCellModel()
        theme.name = .themeString
        theme.haveDisclosureIndicator = true
        theme.nameColor = .gobalTextColor
        theme.disclosureIndicatorImageName = disclosureIndicatorImageName
        
        let userIcon = PTFunctionCellModel()
        userIcon.name = .userIcon
        userIcon.haveDisclosureIndicator = true
        userIcon.nameColor = .gobalTextColor
        userIcon.disclosureIndicatorImageName = disclosureIndicatorImageName

        themeMain.models = [color,userIcon,language,theme]
        
        //MARK: Speech
        let speechMain = PTSettingModels()
        speechMain.name = PTLanguage.share.text(forKey: "about_Main_Speech")

        let speechLanguage = PTFunctionCellModel()
        speechLanguage.name = .speech
        speechLanguage.haveDisclosureIndicator = true
        speechLanguage.nameColor = .gobalTextColor
        speechLanguage.disclosureIndicatorImageName = disclosureIndicatorImageName

        speechMain.models = [speechLanguage]

        //MARK: Chat
        let chatMain = PTSettingModels()
        chatMain.name = "Chat"

        let savedMessage = PTFunctionCellModel()
        savedMessage.name = .savedChat
        savedMessage.haveDisclosureIndicator = true
        savedMessage.nameColor = .gobalTextColor
        savedMessage.disclosureIndicatorImageName = disclosureIndicatorImageName

        let deleteAllChat = PTFunctionCellModel()
        deleteAllChat.name = .deleteAllChat
        deleteAllChat.haveDisclosureIndicator = true
        deleteAllChat.nameColor = .gobalTextColor
        deleteAllChat.disclosureIndicatorImageName = disclosureIndicatorImageName

        let deleteAllVoiceFile = PTFunctionCellModel()
        deleteAllVoiceFile.name = .deleteAllVoiceFile
        deleteAllVoiceFile.haveDisclosureIndicator = true
        deleteAllVoiceFile.nameColor = .gobalTextColor
        deleteAllVoiceFile.disclosureIndicatorImageName = disclosureIndicatorImageName

        chatMain.models = [savedMessage,deleteAllChat,deleteAllVoiceFile]
        
        let apiMain = PTSettingModels()
        apiMain.name = "API"

        //MARK: API
        let aiType = PTFunctionCellModel()
        aiType.name = .apiAIType
        aiType.haveDisclosureIndicator = true
        aiType.nameColor = .gobalTextColor
        aiType.disclosureIndicatorImageName = disclosureIndicatorImageName
        
        let aiSmart = PTFunctionCellModel()
        aiSmart.name = .aiSmart
        aiSmart.nameColor = .gobalTextColor
        
        let drawSize = PTFunctionCellModel()
        drawSize.name = .drawImageSize
        drawSize.haveDisclosureIndicator = true
        drawSize.nameColor = .gobalTextColor
        drawSize.disclosureIndicatorImageName = disclosureIndicatorImageName

        let aiToken = PTFunctionCellModel()
        aiToken.name = .apiAIToken
        aiToken.haveDisclosureIndicator = true
        aiToken.nameColor = .gobalTextColor
        aiToken.disclosureIndicatorImageName = disclosureIndicatorImageName

        let getApiToken = PTFunctionCellModel()
        getApiToken.name = .getAPIAIToken
        getApiToken.haveDisclosureIndicator = true
        getApiToken.nameColor = .gobalTextColor
        getApiToken.disclosureIndicatorImageName = disclosureIndicatorImageName

        apiMain.models = [aiType,aiSmart,drawSize,aiToken,getApiToken]
        
        let otherMain = PTSettingModels()
        otherMain.name = PTLanguage.share.text(forKey: "about_Main_Other")

        //MARK: Other
        let github = PTFunctionCellModel()
        github.name = .github
        github.haveDisclosureIndicator = true
        github.nameColor = .gobalTextColor
        github.disclosureIndicatorImageName = disclosureIndicatorImageName

        let forum = PTFunctionCellModel()
        forum.name = .forum
        forum.haveDisclosureIndicator = true
        forum.nameColor = .gobalTextColor
        forum.disclosureIndicatorImageName = disclosureIndicatorImageName

        let rate = PTFunctionCellModel()
        rate.name = .rate
        rate.haveDisclosureIndicator = true
        rate.nameColor = .gobalTextColor
        rate.disclosureIndicatorImageName = disclosureIndicatorImageName

        let share = PTFunctionCellModel()
        share.name = .share
        share.haveDisclosureIndicator = true
        share.nameColor = .gobalTextColor
        share.disclosureIndicatorImageName = disclosureIndicatorImageName

        let version = PTFunctionCellModel()
        version.name = .version
        version.haveDisclosureIndicator = false
        version.nameColor = .gobalTextColor
        version.content = "v" + kAppVersion!
        version.contentTextColor = .gobalTextColor
        
        otherMain.models = [github,forum,rate,share,version]
        return [themeMain,speechMain,chatMain,apiMain,otherMain]
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
            var cellHeight:CGFloat = 44
            if (model.dataModel as! PTFunctionCellModel).name == .aiSmart
            {
                cellHeight = 78
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
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topTrailing)
        laySection.boundarySupplementaryItems = [headerItem]

        let backItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        backItem.contentInsets = NSDirectionalEdgeInsets.init(top: 10, leading: PTAppBaseConfig.share.defaultViewSpace, bottom: 0, trailing: PTAppBaseConfig.share.defaultViewSpace)
        laySection.decorationItems = [backItem]
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showDetail()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTLanguage.share.text(forKey: "about_Setting")
        self.view.backgroundColor = .gobalScrollerBackgroundColor
        // Do any additional setup after loading the view.
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
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
            let cellSection = PTSection.init(headerTitle:value.name,headerCls:PTSettingHeader.self,headerID: PTSettingHeader.ID,headerHeight: 44,rows: rows)
            mSections.append(cellSection)
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
                        let object:PTAlbumObject = try await PTImagePicker.openAlbum()
                        await MainActor.run{
                            if let imageData = object.imageData,let image = UIImage(data: imageData)
                            {
                                AppDelegate.appDelegate()!.appConfig.userIcon = imageData
                                PTLocalConsoleFunction.share.pNSLog(image)
                            }
                            else
                            {
                                PTLocalConsoleFunction.share.pNSLog("獲取圖片出現錯誤")
                            }
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
            cell.cellModel = (itemRow.dataModel as! PTFunctionCellModel)
            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.topLineView.isHidden = true
            return cell
        }
        else if itemRow.ID == PTAISmartCell.ID
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTAISmartCell
            cell.cellModel = (itemRow.dataModel as! PTFunctionCellModel)
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
            let vc = PTColorSettingViewController()
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
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),msg: PTLanguage.share.text(forKey: "chat_Delete_all_chat"),okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                UserDefaults.standard.set("", forKey: uChatHistory)
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
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
            PTAppStoreFunction.rateApp(appid: "")
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
            let vc = PTDarkModeSettingViewController()
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
            let speechKit = OSSSpeech.shared
            speechKit.delegate = self
            speechKit.deleteVoiceFolderItem(url: nil)
        }
        else if itemRow.title == .drawImageSize
        {
            let wKey = "width"
            let hKey = "height"
            let title = PTLanguage.share.text(forKey: "about_Draw_image_size")
            
            let imageSize = AppDelegate.appDelegate()!.appConfig.aiDrawSize
            
            UIAlertController.base_textfiele_alertVC(title:title,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [wKey,hKey], textFieldTexts: [String(format: "%.0f", imageSize.width),String(format: "%.0f", imageSize.height)], keyboardType: [.numberPad,.numberPad],textFieldDelegate: self) { result in
                let newWidth = result[wKey]!
                let newHeight = result[hKey]!
                
                if ((newWidth.double() ?? 0) > 1024 || (newWidth.double() ?? 0) < 1) && ((newHeight.double() ?? 0) > 1024 || (newHeight.double() ?? 0) < 1)
                {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "size_Wrong"))
                }
                else if ((newWidth.double() ?? 0) > 1024 || (newWidth.double() ?? 0) < 1) && ((newHeight.double() ?? 0) < 1024 || (newHeight.double() ?? 0) > 1)
                {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "size_Wrong"))
                }
                else if ((newWidth.double() ?? 0) < 1024 || (newWidth.double() ?? 0) > 1) && ((newHeight.double() ?? 0) > 1024 || (newHeight.double() ?? 0) < 1)
                {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "size_Wrong"))
                }
                else
                {
                    let saveSize = CGSize(width: newWidth.double()!, height: newHeight.double()!)
                    
                    AppDelegate.appDelegate()!.appConfig.aiDrawSize = saveSize
                }
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
        PTLocalConsoleFunction.share.pNSLog(image)
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

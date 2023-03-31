//
//  PTChatMasterControl.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 31/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import Photos
import SwipeCellKit
import MessageKit
import Instructions

class PTChatMasterControl: PTChatBaseViewController {

    let coachMarkController = CoachMarksController()
    lazy var coachArray:[PTCoachModel] = {
        
        let icon = PTCoachModel()
        icon.info = PTLanguage.share.text(forKey: "appUseInfo_Icon")
        icon.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let userName = PTCoachModel()
        userName.info = PTLanguage.share.text(forKey: "appUseInfo_User_name")
        userName.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let tags = PTCoachModel()
        tags.info = PTLanguage.share.text(forKey: "appUseInfo_Tags")
        tags.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let deleteAllTags = PTCoachModel()
        deleteAllTags.info = PTLanguage.share.text(forKey: "appUseInfo_Deleta_all_tag")
        deleteAllTags.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let cleanChat = PTCoachModel()
        cleanChat.info = PTLanguage.share.text(forKey: "appUseInfo_Clean_chat")
        cleanChat.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let addTag = PTCoachModel()
        addTag.info = PTLanguage.share.text(forKey: "appUseInfo_AddTag")
        addTag.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let setting = PTCoachModel()
        setting.info = PTLanguage.share.text(forKey: "appUseInfo_Setting")
        setting.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        return [icon,userName,tags,deleteAllTags,cleanChat,addTag,setting]
    }()

    lazy var lineView:UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var currentChatViewController:PTChatViewController = {
        if let splitViewController = self.splitViewController,
            let detailViewController = splitViewController.viewControllers.last as? PTNavController {
            // 在这里使用detailViewController
            let chat = detailViewController.viewControllers.first as! PTChatViewController
            return chat
        } else if let detailViewController = self.navigationController?.viewControllers.last as? PTNavController {
            // 在这里使用detailViewController
            let chat = detailViewController.viewControllers.first as! PTChatViewController
            return chat
        } else {
            return PTChatViewController(historyModel: PTSegHistoryModel())
        }
    }()
    
    lazy var userIconButton:UIButton = {
        let view = UIButton(type: .custom)
        view.imageView?.contentMode = .scaleAspectFill
        view.setImage(UIImage(data: AppDelegate.appDelegate()!.appConfig.userIcon), for: .normal)
        view.addActionHandlers { sender in
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { blockStatus in
                    if blockStatus == .authorized {
                        PTGCDManager.gcdMain {
                            self.enterPhotos(string: .userIcon)
                        }
                    }
                }
            } else if status == .authorized {
                self.enterPhotos(string: .userIcon)
            } else if status == .denied {
                let messageString = String(format: PTLanguage.share.text(forKey: "alert_Go_to_photo_setting"), kAppName!)
                PTBaseViewController.gobal_drop(title: messageString)
            } else {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_No_photo_library"))
            }
        }
        return view
    }()
    
    lazy var nameButton:UIButton = {
        let view = UIButton(type: .custom)
        view.titleLabel?.lineBreakMode = .byTruncatingTail
        view.titleLabel?.font = .appfont(size: 20)
        view.setTitleColor(.gobalTextColor, for: .normal)
        view.setTitle(AppDelegate.appDelegate()?.appConfig.userName, for: .normal)
        view.addActionHandlers { sender in
            PTGCDManager.gcdAfter(time: 0.5) {
                let title = PTLanguage.share.text(forKey: "alert_Name_edit_title")
                let placeHolder = PTLanguage.share.text(forKey: "alert_Name_edit_placeholder")
                UIAlertController.base_textfiele_alertVC(title:title,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [placeHolder], textFieldTexts: [AppDelegate.appDelegate()!.appConfig.userName], keyboardType: [.default],textFieldDelegate: self) { result in
                    let userName:String? = result[placeHolder]!
                    if !(userName ?? "").stringIsEmpty() {
                        self.nameButton.setTitle(userName!, for: .normal)
                        AppDelegate.appDelegate()?.appConfig.userName = userName!
                        PTChatData.share.user = PTChatUser(senderId: "000000", displayName: AppDelegate.appDelegate()!.appConfig.userName)
                        PTGCDManager.gcdAfter(time: 0.35) {
                            PTGCDManager.gcdMain {
                                self.reloadTagChat(index: self.segDataArr().firstIndex(where: {$0.keyName == self.currentHistoryModel.keyName})!)
                            }
                        }
                    } else {
                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                    }
                }
            }
        }
        return view
    }()
    
    lazy var bottomContent:UIView = {
        let view = UIView()
        return view
    }()
    
    let popoverCellBaseHeight:CGFloat = 64
    let popoverWidth:CGFloat = iPadSplitMainControl
    let footerHeight:CGFloat = 44
    fileprivate var isSwipeRightEnabled = false

    var currentHistoryModel = PTSegHistoryModel()

    func segDataArr() -> [PTSegHistoryModel] {
        var arr = [PTSegHistoryModel]()
        let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory
        let dataArr = dataString!.components(separatedBy: kSeparatorSeg)
        dataArr.enumerated().forEach { index,value in
            let model = PTSegHistoryModel.deserialize(from: value)
            arr.append(model!)
        }
        return arr
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
        sectionModel.rows.enumerated().forEach { (index,model) in
            let cellHeight:CGFloat = self.popoverCellBaseHeight
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: 0, y: groupH, width: self.popoverWidth, height: cellHeight), zIndex: 1000+index)
            customers.append(customItem)
            groupH += cellHeight
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(iPadSplitMainControl), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
        group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
            customers
        })
        
        let sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        return laySection
    }

    lazy var collectionView : UICollectionView = {
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: self.comboLayout())
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()

    lazy var deleteAllTag:UIButton = {
        let deleteAllTag = UIButton(type: .custom)
        deleteAllTag.setImage("🗑️".emojiToImage(emojiFont: .appfont(size: 34)), for: .normal)
        deleteAllTag.addActionHandlers { sender in
            if self.segDataArr().count == 1 {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_cannot_delete_tag"))
            } else {
                UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_delete_all_tag"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                } moreBtn: { index, title in
                    var arr = AppDelegate.appDelegate()?.appConfig.tagDataArr()
                    arr?.removeAll(where: {$0.keyName != "Base"})

                    if arr?.count == 0 {
                        let baseSub = PTSegHistoryModel()
                        baseSub.keyName = "Base"
                        AppDelegate.appDelegate()!.appConfig.segChatHistory = baseSub.toJSON()!.toJSON()!
                    } else {
                        var newJsonArr = [String]()
                        arr!.enumerated().forEach { index,value in
                            newJsonArr.append(value.toJSON()!.toJSON()!)
                        }
                        AppDelegate.appDelegate()!.appConfig.segChatHistory = newJsonArr.joined(separator: kSeparatorSeg)
                    }
                    self.reloadTagChat(index: 0)
                    self.currentHistoryModel = self.segDataArr()[0]
                    self.showDetail()
                    self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
                }
            }
        }
        return deleteAllTag
    }()
    
    lazy var cleanChat:UIButton = {
        let cleanChat = UIButton(type: .custom)
        cleanChat.setImage("♻️".emojiToImage(emojiFont: .appfont(size: 34)), for: .normal)
        cleanChat.addActionHandlers { sender in
            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_Ask_clean_current_chat_record"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                
            } moreBtn: { index, title in
                self.currentChatViewController.cleanCurrentTagChatHistory()
                PTGCDManager.gcdAfter(time: 0.35) {
                    self.reloadTagChat(index: 0)
                }
            }
        }
        return cleanChat
    }()
    
    lazy var addTag:UIButton = {
        let addTag = UIButton(type: .custom)
        addTag.setImage("🏷️".emojiToImage(emojiFont: .appfont(size: 34)), for: .normal)
        addTag.addActionHandlers { sender in
            PTGCDManager.gcdAfter(time: 0.5) {
                let textKey = PTLanguage.share.text(forKey: "alert_Tag_set")
                let aiKey = PTLanguage.share.text(forKey: "alert_AI_Set")
                UIAlertController.base_textfiele_alertVC(title:textKey,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey,aiKey], textFieldTexts: ["",""], keyboardType: [.default,.default],textFieldDelegate: self) { result in
                    let newKey:String? = result[textKey]!
                    let newAiKey:String? = result[aiKey]
                    if !(newKey ?? "").stringIsEmpty() {
                        if self.segDataArr().contains(where: {$0.keyName == newKey}) {
                            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_error"))
                        } else {
                            var data = self.segDataArr()
                            let newTag = PTSegHistoryModel()
                            newTag.keyName = newKey!
                            newTag.systemContent = newAiKey ?? ""
                            data.append(newTag)
                            var jsonArr = [String]()
                            data.enumerated().forEach { index,value in
                                jsonArr.append(value.toJSON()!.toJSON()!)
                            }
                            AppDelegate.appDelegate()?.appConfig.segChatHistory = jsonArr.joined(separator: kSeparatorSeg)
                            self.reloadTagChat(index: (data.count - 1))
                            self.currentHistoryModel = newTag
                            self.loadData()
                        }
                    } else {
                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                    }
                }
            }
        }
        return addTag
    }()

    lazy var setting:UIButton = {
        let setting = UIButton(type: .custom)
        setting.setImage("⚙️".emojiToImage(emojiFont: .appfont(size: 34)), for: .normal)
        setting.isSelected = false
        setting.addActionHandlers { sender in
            setting.isSelected = !sender.isSelected
            if setting.isSelected {
                let vc = PTSettingListViewController(user: PTChatUser(senderId: "0", displayName: "0"))
                vc.cleanChatListBlock = {
                    self.currentChatViewController.iWillRefresh = true
                }
                self.currentChatViewController.navigationController?.pushViewController(vc)
            } else {
                self.currentChatViewController.navigationController?.popViewController()
            }
        }
        return setting
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !AppDelegate.appDelegate()!.appConfig.apiToken.stringIsEmpty() {
            NotificationCenter.default.addObserver(self, selector: #selector(self.adHide(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdSkipNotification), object: nil)
        }

        self.view.backgroundColor = .gobalBackgroundColor
        
        self.view.addSubviews([self.lineView,self.userIconButton,self.nameButton,self.bottomContent,self.collectionView])
        self.lineView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(1)
            make.top.bottom.equalToSuperview()
        }
        
        let iconSize = iPadSplitMainControl - 192
        self.userIconButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(iconSize)
            make.top.equalToSuperview().inset(CGFloat.statusBarHeight() + 15)
        }
        PTGCDManager.gcdMain {
            self.userIconButton.viewCorner(radius: iconSize / 2)
        }
        
        self.nameButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(self.userIconButton.snp.bottom).offset(10)
            make.height.equalTo(34)
        }
        
        self.bottomContent.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(CGFloat.kTabbarSaveAreaHeight + 64)
        }
                
        self.bottomContent.addSubviews([self.deleteAllTag,self.cleanChat,self.addTag,self.setting])
        self.deleteAllTag.snp.makeConstraints { make in
            make.width.equalTo(iPadSplitMainControl / 4)
            make.height.equalTo(deleteAllTag.snp.width)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        self.cleanChat.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(deleteAllTag)
            make.left.equalTo(deleteAllTag.snp.right)
        }
        self.addTag.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(deleteAllTag)
            make.left.equalTo(cleanChat.snp.right)
        }
        self.setting.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(deleteAllTag)
            make.left.equalTo(addTag.snp.right)
        }
        
        self.currentHistoryModel = self.segDataArr().first!
        
        self.collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.nameButton.snp.bottom).offset(15)
            make.bottom.equalTo(self.bottomContent.snp.top)
        }
        
        self.loadData()
    }
    
    @objc func adHide(notifi:Notification) {
        PTNSLogConsole("广告隐藏")
        
        self.createHolderView()
    }

    func createHolderView() {
        if AppDelegate.appDelegate()!.appConfig.firstCoach {
            self.coachMarkController.overlay.isUserInteractionEnabled = true
            self.coachMarkController.delegate = self
            self.coachMarkController.dataSource = self
            self.coachMarkController.animationDelegate = self
            self.coachMarkController.start(in: .window(over: self))
        }
    }

    func loadData() {
        self.showDetail()
        
        var indexPath = IndexPath()
        self.segDataArr().enumerated().forEach { index,value in
            if value.keyName == self.currentHistoryModel.keyName {
                indexPath = IndexPath.init(row: index, section: 0)
            }
        }
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.segDataArr().enumerated().forEach { (index,value) in
            let row_List = PTRows.init(cls: PTPopoverCell.self, ID: PTPopoverCell.ID, dataModel: value)
            rows.append(row_List)
        }
        
        let sections = PTSection.init(rows: rows)
        mSections.append(sections)

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
                    case .userIcon:
                        AppDelegate.appDelegate()!.appConfig.userIcon = object.pngData()!
                    case .drawRefrence:
                        AppDelegate.appDelegate()!.appConfig.drawRefrence = object.pngData()!
                    default:break
                    }
                    self.userIconButton.setImage(UIImage(data: AppDelegate.appDelegate()!.appConfig.userIcon), for: .normal)
                    
                    self.currentChatViewController.refreshViewAndLoadNewData()
                }
            } catch let pickerError as PTImagePicker.PickerError {
                pickerError.outPutLog()
            }
        }
    }
    
    func reloadTagChat(index:Int) {
        let segModel = self.segDataArr()[index]
        self.currentChatViewController.messageList.removeAll()
        self.currentChatViewController.chatModels.removeAll()
        self.currentChatViewController.messagesCollectionView.reloadData {
            self.currentChatViewController.historyModel = segModel
            self.currentChatViewController.setTitleViewFrame(withModel: segModel)
            self.currentChatViewController.segDataArr = AppDelegate.appDelegate()!.appConfig.tagDataArr()
        }
    }
}

extension PTChatMasterControl:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionFooter {
            if itemSec.footerID == PTPopoverFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTPopoverFooter
                footer.deleteButton.addActionHandlers { sender in
//                    if self.deleteAllTagBlock != nil {
//                        self.deleteAllTagBlock!()
//                    }
//                    self.returnFrontVC()
                }
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
        if itemRow.ID == PTPopoverCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTPopoverCell
            cell.cellModel = (itemRow.dataModel as! PTSegHistoryModel)
            cell.bottomLine.isHidden = indexPath.row == (self.segDataArr().count - 1) ? true : false
            if indexPath.row != 0 {
                cell.delegate = self
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentHistoryModel = self.segDataArr()[indexPath.row]
        self.reloadTagChat(index: indexPath.row)
    }
}

extension PTChatMasterControl:SwipeCollectionViewCellDelegate
{
    func swipe_cell_configure(action: SwipeAction, with descriptor: ActionDescriptor,buttonDisplayMode: ButtonDisplayMode? = PTSaveChatViewController.swipe_cell_buttonDisplayMode(),buttonStyle: ButtonStyle? = PTSaveChatViewController.swipe_cell_buttonStyle()) {
       action.title = descriptor.title(forDisplayMode: buttonDisplayMode!)
       action.image = descriptor.image(forStyle: buttonStyle!, displayMode: buttonDisplayMode!)
       action.hidesWhenSelected = true
       
       switch buttonStyle! {
       case .backgroundColor:
           action.backgroundColor = descriptor.color(forStyle: buttonStyle!)
       case .circular:
           action.backgroundColor = .clear
           action.textColor = descriptor.color(forStyle: buttonStyle!)
           action.font = UIFont.appfont(size: 13)
           action.transitionDelegate = ScaleTransition.default
       }
   }
   
   func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
       var options = SwipeOptions()
       options.expansionStyle = orientation == .left ? .selection : .destructive(automaticallyDelete: false)
       options.transitionStyle = .border
       switch PTSaveChatViewController.swipe_cell_buttonStyle() {
       case .backgroundColor:
           options.buttonSpacing = 4
       case .circular:
           options.buttonSpacing = 4
           options.backgroundColor = .clear
       }
       return options
   }
   
   func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       if orientation == .right {
           
           let delete = SwipeAction(style: .destructive, title: PTLanguage.share.text(forKey: "cell_Delete")) { action, indexPath in
               PTGCDManager.gcdMain {
                   if self.segDataArr()[indexPath.row].keyName == "Base" {
                       PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_error"))
                       self.showDetail()
                   } else if self.segDataArr()[indexPath.row].keyName == self.currentHistoryModel.keyName && self.segDataArr()[indexPath.row].keyName != "Base" {
                       var data = self.segDataArr()
                       data.remove(at: indexPath.row)
                       PTAppConfig.refreshTagData(segDataArr: data)
                       self.reloadTagChat(index: 0)
                       self.showDetail()
                       self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
                   } else {
                       var data = self.segDataArr()
                       data.remove(at: indexPath.row)
                       PTAppConfig.refreshTagData(segDataArr: data)
                       self.showDetail()

                       for (index,value) in self.segDataArr().enumerated() {
                           if value.keyName == self.currentHistoryModel.keyName {
                               self.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
                               break
                           }
                       }
                       
                       PTAppConfig.refreshTagData(segDataArr: data)
                       self.currentChatViewController.segDataArr = data
                   }
               }
           }
           delete.font = .appfont(size: 14)
           delete.backgroundColor = .clear
           delete.fulfill(with: .delete)
           self.swipe_cell_configure(action: delete, with: .trash)
           
           let edit = SwipeAction(style: .destructive, title: "编辑") { action, indexPath in
               PTGCDManager.gcdAfter(time: 0.5) {
                   let itemSec = self.mSections[indexPath.section]
                   let itemRow = itemSec.rows[indexPath.row]
                   let cellModel = (itemRow.dataModel as! PTSegHistoryModel)
                   if cellModel.keyName == "Base" {
                       PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Edit_error"))
                   } else {
                       let textKey = PTLanguage.share.text(forKey: "alert_Tag_set")
                       let aiKey = PTLanguage.share.text(forKey: "alert_AI_Set")
                                          
                       let currentTitle = cellModel.keyName
                       let aiSet = cellModel.systemContent

                       UIAlertController.base_textfiele_alertVC(title:PTLanguage.share.text(forKey: "alert_Edit_ai"),titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey,aiKey], textFieldTexts: [currentTitle,aiSet], keyboardType: [.default,.default],textFieldDelegate: self) { result in
                           let newKey:String? = result[textKey]!
                           let newAiKey:String? = result[aiKey]
                           if !(newKey ?? "").stringIsEmpty() {
                               var segDatas = AppDelegate.appDelegate()?.appConfig.tagDataArr()
                               let currentCellBaseData = segDatas![indexPath.row]
                               currentCellBaseData.keyName = newKey!
                               currentCellBaseData.systemContent = newAiKey ?? ""
                               segDatas![indexPath.row] = currentCellBaseData
                               
                               var jsonArr = [String]()
                               segDatas!.enumerated().forEach { index,value in
                                   jsonArr.append(value.toJSON()!.toJSON()!)
                               }
                               AppDelegate.appDelegate()?.appConfig.segChatHistory = jsonArr.joined(separator: kSeparatorSeg)
                               
                               var indexPathSelect = IndexPath()
                               self.segDataArr().enumerated().forEach { index,value in
                                   if value.keyName == self.currentHistoryModel.keyName {
                                       indexPathSelect = IndexPath.init(row: index, section: 0)
                                   }
                               }
                               var data = self.segDataArr()
                               data[indexPath.row] = currentCellBaseData
                               PTAppConfig.refreshTagData(segDataArr: data)
                               self.showDetail()
                               self.collectionView.selectItem(at: indexPathSelect, animated: false, scrollPosition: .top)
                               
                               if indexPathSelect.row == indexPath.row {
                                   self.reloadTagChat(index: indexPath.row)
                               }
                           } else {
                               PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                           }
                       }
                   }
               }
           }
           edit.font = .appfont(size: 14)
           edit.backgroundColor = .clear
           edit.fulfill(with: .reset)
           self.swipe_cell_configure(action: edit, with: .edit)

           return [delete,edit]
       } else {
           guard isSwipeRightEnabled else { return nil }

           let read = SwipeAction(style: .default, title: nil) { action, indexPath in
           }

           read.hidesWhenSelected = true

           let descriptor: ActionDescriptor = .unread
           self.swipe_cell_configure(action: read, with: descriptor)
           return [read]
       }
   }
}

extension PTChatMasterControl : UITextFieldDelegate {}

extension PTChatMasterControl: CoachMarksControllerDataSource {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: UIView & CoachMarkBodyView, arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )

        coachViews.bodyView.hintLabel.font = .appfont(size: 16)
        coachViews.bodyView.hintLabel.text = self.coachArray[index].info
        coachViews.bodyView.nextLabel.font = .appfont(size: 16)
        coachViews.bodyView.nextLabel.text = self.coachArray[index].next

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return self.coachArray.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: self.userIconButton)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.nameButton)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: self.collectionView)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: self.deleteAllTag)
        case 4:
            return coachMarksController.helper.makeCoachMark(for: self.cleanChat)
        case 5:
            return coachMarksController.helper.makeCoachMark(for: self.addTag)
        case 6:
            return coachMarksController.helper.makeCoachMark(for: self.setting)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
}

extension PTChatMasterControl: CoachMarksControllerAnimationDelegate {
    public func coachMarksController(_ coachMarksController: CoachMarksController,
                              fetchAppearanceTransitionOfCoachMark coachMarkView: UIView,
                              at index: Int,
                              using manager: CoachMarkTransitionManager) {
        manager.parameters.options = [.beginFromCurrentState]
        manager.animate(.regular, animations: { _ in
            coachMarkView.transform = .identity
            coachMarkView.alpha = 1
        }, fromInitialState: {
            coachMarkView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            coachMarkView.alpha = 0
        })
    }

    public func coachMarksController(_ coachMarksController: CoachMarksController,
                              fetchDisappearanceTransitionOfCoachMark coachMarkView: UIView,
                              at index: Int,
                              using manager: CoachMarkTransitionManager) {
        manager.parameters.keyframeOptions = [.beginFromCurrentState]
        manager.animate(.keyframe, animations: { _ in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                coachMarkView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                coachMarkView.alpha = 0
            })
        })
    }

    public func coachMarksController(_ coachMarksController: CoachMarksController,
                              fetchIdleAnimationOfCoachMark coachMarkView: UIView,
                              at index: Int,
                              using manager: CoachMarkAnimationManager) {
        manager.parameters.options = [.repeat, .autoreverse, .allowUserInteraction]
        manager.parameters.duration = 0.7

        manager.animate(.regular, animations: { context in
            let offset: CGFloat = context.coachMark.arrowOrientation == .top ? 10 : -10
            coachMarkView.transform = CGAffineTransform(translationX: 0, y: offset)
        })
    }
}

extension PTChatMasterControl : CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        if index == (self.coachArray.count - 1) {
            self.currentChatViewController.createHolderView()
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        
    }
}

//
//  PTChatViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import PooTools
import MapKit
import AVFAudio
import LXFProtocolTool
import SwifterSwift
import Instructions
import WhatsNew
import SwiftSpinner
import OSSSpeechKit
import Alamofire
import Kingfisher
import AttributedString

fileprivate extension String {
    static let saveNavTitle = PTLanguage.share.text(forKey: "about_SavedChat")
    
    static let copyString = PTLanguage.share.text(forKey: "chat_Copy")
    static let editString = PTLanguage.share.text(forKey: "chat_Edit_question")
    static let playString = PTLanguage.share.text(forKey: "chat_Speak_text")
    static let saveString = PTLanguage.share.text(forKey: "chat_Favourite")
    static let thinking = PTLanguage.share.text(forKey: "chat_Thinking")
    static let resend = PTLanguage.share.text(forKey: "chat_Resend")
}

enum PTChatCase {
    case draw(type:drawType)
    case chat(type:chatType)
    
    enum chatType {
        case normal
        case edit
    }
    
    enum drawType {
        case normal
        case edit
    }
}

class PTChatViewController: MessagesViewController {
                
    enum ChatIsFlag {
        case YES
        case NO
        case PASS
    }
    
    //MARK: 花费按钮
    lazy var tokenButton:BKLayoutButton = {
        let view = BKLayoutButton()
        view.layoutStyle = .leftImageRightTitle
        view.setMidSpacing(5)
        view.setImage("✏️".emojiToImage(emojiFont: .appfont(size: 13)), for: .normal)
        view.setImage("💸".emojiToImage(emojiFont: .appfont(size: 13)), for: .selected)
        view.titleLabel?.font = .appfont(size: 12)
        view.setTitleColor(.gobalTextColor, for: .normal)
        view.setTitleColor(.gobalTextColor, for: .selected)
        view.setTitle(String(format: "%.0f", AppDelegate.appDelegate()!.appConfig.totalToken), for: .normal)
        view.isSelected = false
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            self.setTokenButton()
        }
        return view
    }()
    
    //MARK: 花费记录
    lazy var tokenCostButton : UIButton = {
        let view = UIButton(type: .custom)
        view.setImage("⏱️".emojiToImage(emojiFont: .appfont(size: 13)), for: .normal)
        view.addActionHandlers { sender in
            let vc = PTCostHistoriaViewController()
            self.navigationController?.pushViewController(vc)
        }
        return view
    }()
    
    //MARK: 键盘相关
    //MARK: PS圖片按鈕
    ///PS圖片按鈕
    private lazy var textImageBarButton:InputBarButtonItem = {
        
        let view = InputBarButtonItem()
        view.backgroundColor = .gobalBackgroundColor
        view.spacing = .fixed(10)
        view.backgroundColor = .gobalBackgroundColor
        view.setSize(CGSize(width: 44, height: 44), animated: true)
        view.isSelected = false
        view.setImage(UIImage(systemName: "text.below.photo.fill")?.withTintColor(.gobalTextColor, renderingMode: .automatic), for: .normal)
        view.setImage(UIImage(systemName: "text.below.photo.fill")?.withTintColor(.randomColor, renderingMode: .automatic), for: .selected)
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.voiceButton.removeFromSuperview()
                self.chatCase = .draw(type: .edit)
                self.setEditImageBar()
            } else {
                self.chatCase = .chat(type: .normal)
                self.cleanInputBarTop()
            }
        }
        return view
    }()
    
    //MARK: GPT推薦AI人設
    ///GPT推薦AI人設
    private lazy var tagSuggestionButton:InputBarButtonItem = {
        
        let view = InputBarButtonItem()
        view.backgroundColor = .gobalBackgroundColor
        view.spacing = .fixed(10)
        view.backgroundColor = .gobalBackgroundColor
        view.setSize(CGSize(width: 44, height: 44), animated: true)
        view.setImage("🤖".emojiToImage(emojiFont: .appfont(size: 24)), for: .normal)
        view.addActionHandlers { sender in
            let vc = PTSuggestionControl()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return view
    }()

    //MARK: 其他畫畫按鈕
    ///其他畫畫按鈕
    private lazy var tfImageButton:InputBarButtonItem = {
        let view = InputBarButtonItem()
        view.spacing = .fixed(10)
        view.backgroundColor = .gobalBackgroundColor
        view.isSelected = AppDelegate.appDelegate()!.appConfig.checkSentence
        view.imageView?.contentMode = .scaleAspectFit
        view.setImage("👨‍🎨".emojiToImage(emojiFont: .appfont(size: 24)), for: .normal)
        view.setSize(CGSize(width: 44, height: 44), animated: false)
        view.addActionHandlers { sender in
            
            var actionSheetOption = ""
            if AppDelegate.appDelegate()!.appConfig.canUseStableDiffusionModel() {
                actionSheetOption = PTLanguage.share.text(forKey: "chat_TF")
            } else {
                actionSheetOption = PTLanguage.share.text(forKey: "chat_TF_no_sd")
            }
            
            UIAlertController.baseActionSheet(title: "AI Draw",subTitle: actionSheetOption, titles: self.cartoonImageModes) { sheet in
                
            } cancelBlock: { sheet in
                
            } otherBlock: { sheet, index in
                switch index {
                case 0,1:
                    Task.init {
                        do {
                            let object:UIImage = try await PTImagePicker.openAlbum()
                            let date = Date()
                            let dateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                            let fileName = "cartoon_\(dateString).png"
                            
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    AppDelegate.appDelegate()!.appConfig.saveUserSendImage(image: object, fileName: fileName) { finish in
                                        if finish {
                                            PTGCDManager.gcdMain {
                                                self.setTypingIndicatorViewHidden(false)
                                            }

                                            let saveModel = PTChatModel()
                                            saveModel.messageType = 2
                                            saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                            saveModel.messageSendSuccess = false
                                            saveModel.localFileName = fileName
                                            self.chatModels.append(saveModel)
                                            var message = PTMessageModel(image: object, user: PTChatData.share.user, messageId: UUID().uuidString, date: Date(), sendSuccess: false,fileName: fileName)
                                            message.sending = true
                                            self.historyModel?.historyModel = self.chatModels
                                            PTGCDManager.gcdMain {
                                                self.insertMessage(message) {
                                                    switch self.cartoonImageModes[index] {
                                                    case PTLanguage.share.text(forKey: "chat_TF_Cartoon"):
                                                        self.cartoonGanModel.process(object)
                                                    case PTLanguage.share.text(forKey: "chat_TF_Oil_painting"):
                                                        self.styleTransfererModel.process(object)
                                                    default:break
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } catch let pickerError as PTImagePicker.PickerError {
                            pickerError.outPutLog()
                        }
                    }
                default:
                    if #available(iOS 15.4, *) {
                        let vc = PTDiffusionViewController()
                        self.navigationController?.pushViewController(vc)
                    }
                }
            } tapBackgroundBlock: { sheet in
                
            }
        }
        return view
    }()
    
    //MARK: 檢測是否不雅語句按鈕
    ///檢測是否不雅語句按鈕
    private lazy var inputBarChatSentence:InputBarButtonItem = {
        let view = InputBarButtonItem()
        view.backgroundColor = .gobalBackgroundColor
        view.isSelected = AppDelegate.appDelegate()!.appConfig.checkSentence
        view.imageView?.contentMode = .scaleAspectFit
        view.setImage("🤬".emojiToImage(emojiFont: .appfont(size: 24)), for: .normal)
        view.setImage("🤫".emojiToImage(emojiFont: .appfont(size: 24)), for: .selected)
        view.setSize(CGSize(width: 44, height: 44), animated: false)
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            AppDelegate.appDelegate()!.appConfig.checkSentence = sender.isSelected
        }
        return view
    }()
    
    private lazy var inputBarCloseEditButton:InputBarButtonItem = {
        
        let view = InputBarButtonItem()
        view.backgroundColor = .gobalBackgroundColor
        view.spacing = .fixed(10)
        view.isSelected = false
        view.titleLabel?.font = .appfont(size: 12)
        view.titleLabel?.numberOfLines = 0
        view.setImage(UIImage(systemName: "xmark.circle.fill")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.addActionHandlers { sender in
            self.editString = ""
            self.chatCase = .chat(type: .normal)
            self.messageInputBar.inputTextView.resignFirstResponder()
            self.messageInputBar.inputTextView.placeholder = "Aa"
            self.messageInputBar.setStackViewItems([], forStack: .top, animated: true)
        }
        return view
    }()
            
    //MARK: 語音發送開關
    ///語音發送開關
    private func leftInputStackButton() -> InputBarButtonItem {
        let view = InputBarButtonItem()
        view.spacing = .fixed(10)
        view.setSize(CGSize(width: 34, height: 34), animated: true)
        view.isSelected = false
        view.setImage(UIImage(systemName: "mic")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setImage(UIImage(systemName: "mic.fill")?.withTintColor(.black, renderingMode: .automatic), for: .selected)
        view.addActionHandlers { sender in
            self.messageInputBar.inputTextView.resignFirstResponder()
            if self.voiceCanTap {
                self.chatCase = .chat(type: .normal)
                self.cleanInputBarTop()
                sender.isSelected = !sender.isSelected
                if sender.isSelected {
                    if !self.messageInputBar.inputTextView.text.stringIsEmpty() {
                        self.tapVoiceSaveString = self.messageInputBar.inputTextView.text
                        self.messageInputBar.inputTextView.text = ""
                    }
                    self.messageInputBar.addSubview(self.voiceButton)
                    self.voiceButton.snp.makeConstraints { make in
                        make.left.right.centerY.top.bottom.equalTo(self.messageInputBar.inputTextView)
                    }
                } else {
                    if !self.tapVoiceSaveString.stringIsEmpty() {
                        self.messageInputBar.inputTextView.text = self.tapVoiceSaveString
                    }
                    self.tapVoiceSaveString = ""
                    self.voiceButton.removeFromSuperview()
                }
            } else {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Can_not_send_voice"))
            }
        }
        return view
    }
    
    //MARK: 根據文字回答文字,根據文字回答圖片按鈕
    ///根據文字回答文字,根據文字回答圖片按鈕
    private lazy var rightInputStackButton : InputBarButtonItem = {
        let view = InputBarButtonItem()
        view.spacing = .fixed(10)
        view.setSize(CGSize(width: 34, height: 34), animated: true)
        view.isSelected = false
        view.setImage(UIImage(systemName: "character.bubble.fill")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setImage(UIImage(systemName: "paintbrush.fill")?.withTintColor(.black, renderingMode: .automatic), for: .selected)
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                switch self.chatCase {
                case .draw(type: .edit):
                    self.cleanInputBarTop()
                default:
                    break
                }
                self.chatCase = .draw(type:.normal)
            } else {
                switch self.chatCase {
                case .draw(type: .edit):
                    self.cleanInputBarTop()
                default:
                    break
                }
                self.chatCase = .chat(type:.normal)
            }
        }
        return view
    }()
    
    //MARK: 根據圖片獲取相似圖片按鈕
    ///根據圖片獲取相似圖片按鈕
    private lazy var imageBarButton:InputBarButtonItem = {
        
        let view = InputBarButtonItem()
        view.backgroundColor = .gobalBackgroundColor
        view.spacing = .fixed(10)
        view.setSize(CGSize(width: 44, height: 44), animated: true)
        view.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill")?.withTintColor(.gobalTextColor, renderingMode: .automatic), for: .normal)
        view.addActionHandlers { sender in
            PTGCDManager.gcdAfter(time: 0.35) {
                Task.init {
                    do {
                        let object:UIImage = try await PTImagePicker.openAlbum()
                        
                        let date = Date()
                        let dateString = date.dateFormat(formatString: "yyyy-MM-dd-HH-mm-ss")
                        let fileName = "\(dateString).png"
                        
                        PTGCDManager.gcdMain {
                            AppDelegate.appDelegate()!.appConfig.saveUserSendImage(image: object, fileName: "\(dateString).png") { finish in
                                if finish {
                                    let saveModel = PTChatModel()
                                    saveModel.messageType = 2
                                    saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                    saveModel.messageSendSuccess = false
                                    saveModel.localFileName = "\(dateString).png"
                                    
                                    var message = PTMessageModel(image: object, user: PTChatData.share.user, messageId: UUID().uuidString, date: Date(), sendSuccess: false,fileName: fileName)
                                    message.sending = true
                                    self.insertMessage(message) {
                                        self.messageList[(self.messageList.count - 1)].sending = true
                                        self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                        self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                            PTNSLogConsole("开始发送")
                                            self.userSendImage(imageObject: object, saveModel: saveModel)
                                        }
                                    }
                                }
                            }
                        }
                    } catch let pickerError as PTImagePicker.PickerError {
                        pickerError.outPutLog()
                    }
                }
            }
        }
        return view
    }()

    private lazy var editCloseButton : InputBarButtonItem = {
        let view = InputBarButtonItem()
        view.spacing = .flexible
        view.setImage(UIImage(systemName: "xmark.circle.fill")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setSize(CGSize(width: 44, height: 44), animated: false)
        view.addActionHandlers { sender in
            self.chatCase = .chat(type: .normal)
            self.cleanInputBarTop()
        }
        return view
    }()
    
    private lazy var editMainImageButton : InputBarButtonItem = {
        let view = InputBarButtonItem()
        view.backgroundColor = .clear
        view.spacing = .flexible
        view.titleLabel?.font = .appfont(size: 12)
        view.titleLabel?.numberOfLines = 0
        view.setImage(UIImage(systemName: "rectangle.stack.badge.plus")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setSize(CGSize(width: 44, height: 44), animated: false)
        view.addActionHandlers { sender in
            Task.init {
                do {
                    let object:UIImage = try await PTImagePicker.openAlbum()
                    self.editMainImageButton.setImage(object, for: .normal)
                } catch let pickerError as PTImagePicker.PickerError {
                    pickerError.outPutLog()
                }
            }
        }
        return view
    }()
    
    private lazy var editMaskImageButton : InputBarButtonItem = {
        let view = InputBarButtonItem()
        view.backgroundColor = .clear
        view.spacing = .flexible
        view.titleLabel?.font = .appfont(size: 12)
        view.titleLabel?.numberOfLines = 0
        view.setImage(UIImage(systemName: "rectangle.center.inset.filled.badge.plus")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setSize(CGSize(width: 44, height: 44), animated: false)
        view.addActionHandlers { sender in
            Task.init {
                do {
                    let object:UIImage = try await PTImagePicker.openAlbum()
                    self.editMaskImageButton.setImage(object, for: .normal)
                } catch let pickerError as PTImagePicker.PickerError {
                    pickerError.outPutLog()
                }
            }
        }
        return view
    }()
//MARK: 键盘相关分割线
    
    var mainImage:UIImage?
    var maskImage:UIImage?
    
    let cartoonImageModes : [String] = {
        if AppDelegate.appDelegate()!.appConfig.canUseStableDiffusionModel() {
            return [PTLanguage.share.text(forKey: "chat_TF_Cartoon"),PTLanguage.share.text(forKey: "chat_TF_Oil_painting"),PTLanguage.share.text(forKey: "Stable Diffusion")]
        } else {
            return [PTLanguage.share.text(forKey: "chat_TF_Cartoon"),PTLanguage.share.text(forKey: "chat_TF_Oil_painting")]
        }
    }()
    
    private lazy var styleTransfererModel: StyleTransfererModel = {
        let model = StyleTransfererModel()
        model.delegate = self
        return model
    }()

    private lazy var cartoonGanModel: CartoonGanModel = {
        let model = CartoonGanModel()
        model.delegate = self
        return model
    }()
    
    var chatModels = [PTChatModel]()
    
    let coachMarkController = CoachMarksController()
    lazy var coachArray:[PTCoachModel] = {
        
        let option = PTCoachModel()
        option.info = PTLanguage.share.text(forKey: "appUseInfo_Title_view")
        option.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let tags = PTCoachModel()
        tags.info = PTLanguage.share.text(forKey: "appUseInfo_Option")
        tags.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let setting = PTCoachModel()
        setting.info = PTLanguage.share.text(forKey: "appUseInfo_Setting")
        setting.next = PTLanguage.share.text(forKey: "appUseInfo_Next")
        
        let textDraw = PTCoachModel()
        textDraw.info = PTLanguage.share.text(forKey: "suggesstion_Text_draw")
        textDraw.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let imageLike = PTCoachModel()
        imageLike.info = PTLanguage.share.text(forKey: "suggesstion_Like")
        imageLike.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let contentDraw = PTCoachModel()
        contentDraw.info = PTLanguage.share.text(forKey: "suggesstion_Content_draw")
        contentDraw.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let psPhoto = PTCoachModel()
        psPhoto.info = PTLanguage.share.text(forKey: "suggesstion_PS")
        psPhoto.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let sentence = PTCoachModel()
        sentence.info = PTLanguage.share.text(forKey: "suggesstion_Sentence_switch")
        sentence.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let aiDraw = PTCoachModel()
        aiDraw.info = PTLanguage.share.text(forKey: "suggesstion_AI_draw")
        aiDraw.next = PTLanguage.share.text(forKey: "appUseInfo_Next")

        let bot = PTCoachModel()
        bot.info = PTLanguage.share.text(forKey: "bot_Suggesstion")
        bot.next = PTLanguage.share.text(forKey: "appUseInfo_Finish")

        if Gobal_device_info.isPad {
            return [textDraw,imageLike,psPhoto,sentence,aiDraw,bot]
        } else {
            return [option,tags,setting,textDraw,imageLike,psPhoto,sentence,aiDraw,bot]
        }
    }()
        
    var iWillRefresh:Bool = false
    lazy var settingButton:UIButton = {
        let view = UIButton(type: .custom)
        view.imageView?.contentMode = .scaleAspectFit
        view.setImage(UIImage(systemName: "gear")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.addActionHandlers { sender in
            let vc = PTSettingListViewController(user: PTChatUser(senderId: "0", displayName: "0"))
            vc.cleanChatListBlock = {
                self.iWillRefresh = true
            }
            self.navigationController?.pushViewController(vc)
        }
        return view
    }()
    
    lazy var optionButton:UIButton = {
        let addChat = UIButton(type: .custom)
        addChat.imageView?.contentMode = .scaleAspectFit
        addChat.setImage(UIImage(systemName: "ellipsis.circle.fill")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        addChat.addActionHandlers { sender in
            let popover = PTPopoverMenuControl()
            popover.view.backgroundColor = .gobalBackgroundColor.withAlphaComponent(0.45)
            self.popover(popoverVC: popover, popoverSize: CGSize(width: popover.popoverWidth, height: CGFloat(popover.cellModels.count) * popover.popoverCellBaseHeight), sender: sender, arrowDirections: .up)
            popover.selectActionBlock = { string in
                switch string {
                case .addTag:
                    PTGCDManager.gcdAfter(time: 0.5) {
                        let textKey = PTLanguage.share.text(forKey: "alert_Tag_set")
                        let aiKey = PTLanguage.share.text(forKey: "alert_AI_Set")
                        UIAlertController.base_textfiele_alertVC(title:textKey,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey,aiKey], textFieldTexts: ["",""], keyboardType: [.default,.default],textFieldDelegate: self) { result in
                            let newKey:String? = result[textKey]!
                            let newAiKey:String? = result[aiKey]
                            if !(newKey ?? "").stringIsEmpty() {
                                if self.segDataArr.contains(where: {$0?.keyName == newKey}) {
                                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_error"))
                                } else {
                                    let newTag = PTSegHistoryModel()
                                    newTag.keyName = newKey!
                                    newTag.systemContent = newAiKey ?? ""
                                    self.segDataArr.append(newTag)
                                    
                                    AppDelegate.appDelegate()!.appConfig.setChatData = self.segDataArr.kj.JSONObjectArray()
                                    
                                    self.messageList.removeAll()
                                    self.chatModels.removeAll()
                                    self.messagesCollectionView.reloadData {
                                        self.historyModel = newTag
                                        self.setTitleViewFrame(withModel: self.historyModel!)
                                    }
                                }
                            } else {
                                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                            }
                        }
                    }
                case .deleteHistory:
                    popover.dismiss(animated: true) {
                        PTGCDManager.gcdAfter(time: 0.35) {
                            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_Ask_clean_current_chat_record"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                                
                            } moreBtn: { index, title in
                                if self.historyModel!.historyModel.count > 0 {
                                    self.cleanCurrentTagChatHistory()
                                    PTGCDManager.gcdAfter(time: 0.35) {
                                        self.refreshViewAndLoadNewData()
                                    }
                                } else {
                                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_error"))
                                }
                            }
                        }
                    }
                default:break
                }
            }
        }
        return addChat
    }()
    
    func cleanCurrentTagChatHistory() {
        self.historyModel?.historyModel = []
        self.packChatData()
        self.refreshCurrentTagData()
        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
    }
    
    lazy var titleButton:BKLayoutButton = {
        let view = BKLayoutButton()
        view.titleLabel?.lineBreakMode = .byTruncatingTail
        view.titleLabel?.numberOfLines = 2
        view.titleLabel?.font = .appfont(size: 24,bold: true)
        view.setTitleColor(.gobalTextColor, for: .normal)
        view.layoutStyle = .leftTitleRightImage
        if !Gobal_device_info.isPad {
            view.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
            view.setMidSpacing(5)
        } else {
            view.isUserInteractionEnabled = false
        }
        view.addActionHandlers { sender in
            let popover = PTPopoverControl(currentSelect: self.historyModel!)
            popover.view.backgroundColor = .gobalBackgroundColor.withAlphaComponent(0.45)
            self.popover(popoverVC: popover, popoverSize: CGSize(width: popover.popoverWidth, height: CGFloat(popover.segDataArr.count) * popover.popoverCellBaseHeight + (popover.segDataArr.count > 1 ? popover.footerHeight : 0)), sender: sender, arrowDirections: .up)
            popover.selectedBlock = { model in
                self.messageList.removeAll()
                self.chatModels.removeAll()
                self.messagesCollectionView.reloadData {
                    self.historyModel = model
                    self.setTitleViewFrame(withModel: self.historyModel!)
                    self.segDataArr = AppDelegate.appDelegate()!.appConfig.tagDataArr()
                }
            }
            popover.refreshTagArr = {
                self.segDataArr = AppDelegate.appDelegate()!.appConfig.tagDataArr()
            }
            popover.deleteAllTagBlock = {
                PTGCDManager.gcdAfter(time: 0.5) {
                    var arr = AppDelegate.appDelegate()?.appConfig.tagDataArr()
                    arr?.removeAll(where: {$0!.keyName != "Base"})

                    if arr?.count == 0 {
                        let baseSub = PTSegHistoryModel()
                        baseSub.keyName = "Base"
                        AppDelegate.appDelegate()!.appConfig.setChatData = [baseSub.toJSON()!]
                        self.historyModel = baseSub
                    } else {
                        
                        AppDelegate.appDelegate()!.appConfig.setChatData = arr!.kj.JSONObjectArray()
                        self.historyModel = (arr!.first!!)
                    }
                    self.setTitleViewFrame(withModel: self.historyModel!)
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
                }
            }
            popover.refreshCurrentTag = { newTagModel in
                self.historyModel = newTagModel
                self.setTitleViewFrame(withModel: self.historyModel!)
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_success"))
            }
        }
        return view
    }()
        
    var segDataArr:[PTSegHistoryModel?] = {
        return AppDelegate.appDelegate()!.appConfig.tagDataArr()
    }()

    lazy var maskView:PTVoiceActionView = {
        let view = PTVoiceActionView()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        return view
    }()
        
    var sendTranslateText:Bool = false
    var translateToText:Bool = false
    lazy var soundRecorder = PTSoundRecorder()
    
    var chatCase:PTChatCase = .chat(type: .normal)
    
    lazy var audioPlayer = PTAudioPlayer(messageCollectionView: messagesCollectionView)

    var editString:String = ""
        
    let apiShare = PTChatApiFunction.share
    
    lazy var messageList:[PTMessageModel] = []
    let speechKit = OSSSpeech.shared
        
    private(set) lazy var refreshControl:UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessage), for: .valueChanged)
        return control
    }()
    
    lazy var tapVoiceSaveString = ""
    var isRecording:Bool = false
    var isSendVoice:Bool = false
    
    //MARK: 發送語音按鈕
    ///發送語音按鈕
    lazy var voiceButton:UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = .white
        view.addTarget(self, action: #selector(self.recordButtonPressed), for: .touchDown)
        view.addTarget(self, action: #selector(self.recordButtonReleased), for: .touchUpInside)
        view.addTarget(self, action: #selector(self.recordButtonReleased), for: .touchUpOutside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.3
        view.addGestureRecognizer(longPressRecognizer)
        view.viewCorner(radius: 5, borderWidth: 1, borderColor: .black)
        view.setTitle(PTLanguage.share.text(forKey: "button_Long_tap"), for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()
    
    var voiceCanTap:Bool = false

    var onlyShowSave:Bool = false
    
    var historyModel:PTSegHistoryModel? {
        didSet {
            AppDelegate.appDelegate()!.appConfig.currentSelectTag = self.historyModel!.keyName
            self.refreshViewAndLoadNewData()
        }
    }
    
    init(historyModel:PTSegHistoryModel) {
        super.init(nibName: nil, bundle: nil)
        self.historyModel = historyModel
    }
    
    init(token:String,language:OSSVoiceEnum) {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(saveModel:[PTChatModel]) {
        super.init(nibName: nil, bundle: nil)
        self.onlyShowSave = true
                
        saveModel.enumerated().forEach { index,value in
            switch value.messageType {
            case 0:
                let messageSender = value.outgoing ? PTChatData.share.user : PTChatData.share.bot
                let messageModel = PTMessageModel(text: value.messageText, user: messageSender, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date,sendSuccess: value.messageSendSuccess)
                self.messageList.append(messageModel)
            case 1:
                let voiceURL = self.speechKit.getDocumentsDirectory().appendingPathComponent(value.messageMediaURL)
                let messageModel = PTMessageModel(audioURL: voiceURL, user: PTChatData.share.user, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date, sendSuccess: value.messageSendSuccess)
                self.messageList.append(messageModel)
            case 2:
                let messageModel = PTMessageModel(imageURL: URL(string: value.messageMediaURL)!, user: PTChatData.share.bot, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date)
                self.messageList.append(messageModel)
            default:break
            }
            
            self.messagesCollectionView.reloadData {
                self.messagesCollectionView.scrollToLastItem()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarManager.shared.style
    }
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarManager.shared.isHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Gobal_device_info.isPad {
            HSNavControl.GobalNavControl(nav: self.navigationController!,textColor: .gobalTextColor,navColor: .gobalBackgroundColor)
        }
        messagesCollectionView.contentInsetAdjustmentBehavior = .automatic
        
        StatusBarManager.shared.style = PTDarkModeOption.isLight ? .lightContent : .darkContent
        setNeedsStatusBarAppearanceUpdate()
        self.cartoonGanModel.start()
        self.styleTransfererModel.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.maskView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        StatusBarManager.shared.style = PTDarkModeOption.isLight ? .lightContent : .darkContent
        setNeedsStatusBarAppearanceUpdate()

        self.messagesCollectionView.reloadData()
        AppDelegate.appDelegate()?.window?.addSubview(self.maskView)
        self.maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if self.iWillRefresh {
            self.refreshCurrentTagData()
            self.iWillRefresh = false
        }
        
        if !self.onlyShowSave {
            if Gobal_device_info.isPad {
                self.additionalBottomInset = 114
            } else {
                self.additionalBottomInset = 94
            }
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        if !AppDelegate.appDelegate()!.appConfig.apiToken.stringIsEmpty() {
            NotificationCenter.default.addObserver(self, selector: #selector(self.showURLNotifi(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdDetailDisplayNotification), object: nil)
            if !Gobal_device_info.isPad {
                NotificationCenter.default.addObserver(self, selector: #selector(self.adHide(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdSkipNotification), object: nil)
            }
        } else {
            if !Gobal_device_info.isPad {
                NotificationCenter.default.addObserver(self, selector: #selector(self.adHide(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdSkipNotification), object: nil)
            }
        }
        
        self.configureMessageCollectionView()
        speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum(rawValue: AppDelegate.appDelegate()!.appConfig.language)!)
        speechKit.utterance?.rate = 0.45
        if self.onlyShowSave {
            self.title = .saveNavTitle
            messageInputBar.delegate = nil
            messageInputBar.removeFromSuperview()
            messageInputBar.alpha = 0
            
            let back = UIButton(type: .custom)
            back.imageView?.contentMode = .scaleAspectFit
            back.setImage(UIImage(systemName: "chevron.left")!.withTintColor(.gobalTextColor, renderingMode: .automatic), for: .normal)
            back.bounds = CGRect(x: 0, y: 0, width: 34, height: 34)
            back.addActionHandlers { sender in
                self.navigationController?.popViewController()
            }
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshView), name: NSNotification.Name(rawValue: kRefreshController), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshViewAndLoadNewData), name: NSNotification.Name(rawValue: kRefreshControllerAndLoadNewData), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCurrentTagData), name: NSNotification.Name(rawValue: kRefreshCurrentTagData), object: nil)

            if !Gobal_device_info.isPad {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settingButton)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.optionButton)
            }
            self.navigationItem.titleView = self.titleButton
            
#if DEBUG
//            AppDelegate.appDelegate()!.appConfig.firstCoach = true
//            UserDefaults.standard.removeObject(forKey: "LatestAppVersionPresented")
//            UserDefaults.standard.synchronize()

//            let baseSub = PTSegHistoryModel()
//            baseSub.keyName = "Base"
//            let jsonArr = [baseSub.toJSON()!.toJSON()!]
//            let dataString = jsonArr.joined(separator: kSeparatorSeg)
//            AppDelegate.appDelegate()?.appConfig.segChatHistory = dataString
#endif
            SwiftSpinner.useContainerView(AppDelegate.appDelegate()!.window)
            SwiftSpinner.setTitleFont(UIFont.appfont(size: 24))
                        
            self.speechKit.onUpdate = { soundSamples in
                PTNSLogConsole(">>>>>>>>>>>>>>\(soundSamples)")
                PTGCDManager.gcdMain {
                    self.maskView.visualizerView.updateSamples(soundSamples)
                }
            }
            
            self.configureMessageInputBar()

            self.speechKit.delegate = self
                        
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    self.configureMessageInputBar()
                }
            }
        }
                
        self.speechKit.srp.requestAuthorization { authStatus in
            let status = OSSSpeechKitAuthorizationStatus(rawValue: authStatus.rawValue) ?? .notDetermined
            switch status {
            case .authorized:
                self.voiceCanTap = true
            default:
                self.voiceCanTap = false
            }
        }
        
        self.showEmptyDataSet(currentScroller: self.messagesCollectionView)
        self.lxf_tapEmptyView(self.messagesCollectionView) { sender in
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
                        
        self.maskView.alpha = 0
        
        self.pt_observerLanguage {
            self.refreshViewAndLoadNewData()
            self.showEmptyDataSet(currentScroller: self.messagesCollectionView)
            self.messageInputBar.sendButton.setTitle(PTLanguage.share.text(forKey: "chat_Send"), for: .normal)
        }
    }
        
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }

    @objc func refreshView() {
        self.messagesCollectionView.reloadData()
    }
        
    @objc func refreshCurrentTagData() {
        let arr = AppDelegate.appDelegate()?.appConfig.tagDataArr()
        for (value) in arr! {
            if value!.keyName == self.historyModel!.keyName {
                self.historyModel = value
                break
            }
        }
    }
    
    @objc func refreshViewAndLoadNewData(endBlock:(()->Void)? = nil) {
        self.chatModels.removeAll()
        self.messageList.removeAll()
        if self.historyModel!.historyModel.count > 0 {
            self.historyModel!.historyModel.enumerated().forEach { index,value in
                self.chatModels.append(value)
                switch value.messageType {
                case 0:
                    let messageSender = value.outgoing ? PTChatData.share.user : PTChatData.share.bot
                    if !value.editMainName.stringIsEmpty() || !value.editMaskName.stringIsEmpty() {
                        
                        let mainImage:UIImage = AppDelegate.appDelegate()!.appConfig.getMessageImage(name: "\(value.editMainName)")
                        var maskImage:UIImage?
                        if !value.editMaskName.stringIsEmpty() {
                            maskImage = AppDelegate.appDelegate()!.appConfig.getMessageImage(name: "\(value.editMaskName)")
                        }
                        
                        let textString = !value.starString.stringIsEmpty() ? value.starString : value.messageText
                                  
                        var total:ASAttributedString = ASAttributedString("")
                        
                        let attMain:ASAttributedString = """
                        \(wrap: .embedding("""
                        \("\(textString)",.foreground(AppDelegate.appDelegate()!.appConfig.userTextColor))
                        \(.image(mainImage,.custom(size:.init(width:100,height:100))))
                        """))
                        """
                        total += attMain
                        if maskImage != nil {
                            let attMask:ASAttributedString = """
                            \(wrap: .embedding("""
                            \(.image(maskImage!,.custom(size:.init(width:100,height:100))))
                            """))
                            """
                            total += attMask
                        }
                        
                        let message = PTMessageModel(attributedText: total.value, user: messageSender, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date, sendSuccess: value.messageSendSuccess)
                        self.messageList.append(message)
                    } else {
                        let textString = !value.starString.stringIsEmpty() ? value.starString : value.messageText
                        let messageModel = PTMessageModel(text: textString, user: messageSender, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date,sendSuccess: value.messageSendSuccess,correctionText:value.correctionText)
                        self.messageList.append(messageModel)
                    }
                case 1:
                    let voiceURL = self.speechKit.getDocumentsDirectory().appendingPathComponent(value.messageMediaURL)
                    let messageModel = PTMessageModel(audioURL: voiceURL, user: PTChatData.share.user, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date, sendSuccess: value.messageSendSuccess)
                    self.messageList.append(messageModel)
                case 2:
                    var outGoingMediaUrl:URL
                    if value.outgoing {
                        if !value.messageMediaURL.stringIsEmpty() {
                            outGoingMediaUrl = URL(string: value.messageMediaURL)!
                        } else {
                            outGoingMediaUrl = AppDelegate.appDelegate()!.appConfig.getMessageImagePath(name: value.localFileName)
                        }
                    } else {
                        if !value.messageMediaURL.stringIsEmpty() {
                            outGoingMediaUrl = URL(string: value.messageMediaURL)!
                        } else {
                            outGoingMediaUrl = AppDelegate.appDelegate()!.appConfig.getMessageImagePath(name: value.localFileName)
                        }
                    }
                    
                    let messageModel = PTMessageModel(imageURL: outGoingMediaUrl, user: value.outgoing ? PTChatData.share.user : PTChatData.share.bot, messageId: UUID().uuidString, date: value.messageDateString.toDate()!.date,sendSuccess: value.messageSendSuccess)
                    self.messageList.append(messageModel)
                default:break
                }
                
                if index == (self.historyModel!.historyModel.count - 1) {
                    self.messagesCollectionView.reloadData {
                        self.messagesCollectionView.scrollToLastItem()
                    }
                    PTGCDManager.gcdAfter(time: 0.35) {
                        if endBlock != nil {
                            endBlock!()
                        }
                    }
                }
            }
        } else {
            self.messagesCollectionView.reloadData {
                PTGCDManager.gcdAfter(time: 0.35) {
                    if endBlock != nil {
                        endBlock!()
                    }
                }
            }
        }
    }
    
    @objc func showURLNotifi(notifi:Notification) {
        let urlString = (notifi.object as! [String:String])["URLS"]
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func adHide(notifi:Notification) {
        PTNSLogConsole("广告隐藏")
        messageInputBar.alpha = 1
        
        #if DEBUG
        let keySetting = PTSettingViewController()
        keySetting.skipBlock = {
            self.firstCoach()
        }
        PTFloatingPanelFuction.floatPanel_VC(vc:keySetting,panGesDelegate:self,currentViewController:self) {
            self.firstCoach()
        }
        #else
        if !Gobal_device_info.isPad {
            if AppDelegate.appDelegate()!.appConfig.firstUseApp {
                AppDelegate.appDelegate()!.appConfig.firstUseApp = false
                let keySetting = PTSettingViewController()
                keySetting.skipBlock = {
                    self.firstCoach()
                }
                PTFloatingPanelFuction.floatPanel_VC(vc:keySetting,panGesDelegate:self,currentViewController:self) {
                    self.firstCoach()
                }
            } else {
                PTGCDManager.gcdAfter(time: 0.5) {
                    self.createHolderView()
                }
            }
        }
        #endif
    }
    
    //MARK: 第一次使用的提示
    ///第一次使用的提示
    func createHolderView() {
        self.firstCoach()
    }
    
    func firstCoach() {
        if AppDelegate.appDelegate()!.appConfig.firstCoach {
            self.coachMarkController.overlay.isUserInteractionEnabled = true
            self.coachMarkController.delegate = self
            self.coachMarkController.dataSource = self
            self.coachMarkController.animationDelegate = self
            self.coachMarkController.start(in: .window(over: self))
        } else {
            self.whatNews()
        }
    }
    
    //MARK: APP更新了什么
    ///APP更新了什么
    func whatNews() {
        if WhatsNew.shouldPresent() {
            let whatsNew = WhatsNewViewController(items: [
                WhatsNewItem.text(title: "其他", subtitle: "修复了一些昆虫")
                ])
            whatsNew.titleText = "What's New"
            whatsNew.itemSubtitleColor = .lightGray
            whatsNew.buttonText = "Continue"
            present(whatsNew, animated: true, completion: nil)
            whatsNew.onDismissal = {
#if DEBUG
                UserDefaults.standard.removeObject(forKey: "LatestAppVersionPresented")
                UserDefaults.standard.synchronize()
#endif
                StatusBarManager.shared.style = PTDarkModeOption.isLight ? .lightContent : .darkContent
                self.setNeedsStatusBarAppearanceUpdate()

                self.showKeyboard()
                                
                self.loadViewData()
                PTGCDManager.gcdAfter(time: 1) {
                    self.checkTF()
                }
            }
        } else {
            self.loadViewData()
            PTGCDManager.gcdAfter(time: 1) {
                self.checkTF()
            }
        }
    }
    
    func showKeyboard() {
        self.messageInputBar.alpha = 1
        self.messageInputBar.isHidden = false
        self.view.addSubview(self.messageInputBar)
        self.messageInputBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    //MARK: 这里是检查TestFlight的信息
    ///这里是检查TestFlight的信息
    func checkTF() {
        if UIApplication.applicationEnvironment() == .appStore {
            AppDelegate.appDelegate()!.appConfig.appCount += 1
            if AppDelegate.appDelegate()!.appConfig.appCount % 5 == 0 {
                PTCheckTestFlight.share.checkFunction { can in
                    if can {
                        PTGCDManager.gcdMain {
                            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_TF"),msgColor: .gobalTextColor, okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                                
                            } moreBtn: { index, title in
                                let url = URL(string: "https://testflight.apple.com/join/6XpIFw9m")!
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                }
            } else {
                PTCheckUpdateFunction.share.checkTheVersionWithappid(appid: AppAppStoreID, test: false, url: nil, version: nil, note: nil, force: true)
            }
        } else if UIApplication.applicationEnvironment() == .testFlight {
            PTCheckUpdateFunction.share.checkTheVersionWithappid(appid: AppAppStoreID, test: false, url: nil, version: nil, note: nil, force: true)
        } else {
            PTCheckUpdateFunction.share.checkTheVersionWithappid(appid: AppAppStoreID, test: false, url: nil, version: nil, note: nil, force: true)
        }
    }
    
    func loadViewData() {
        
        let arr = AppDelegate.appDelegate()?.appConfig.tagDataArr()
        if arr!.count > 6 {
            PTGCDManager.gcdAfter(time: 3) {
                SwiftSpinner.show(duration: 3, title: "Loading............")
            }
        }
        
        let currentTag = AppDelegate.appDelegate()!.appConfig.currentSelectTag
        
        self.historyModel = arr![arr?.firstIndex(where: {$0?.keyName == currentTag}) ?? 0]
        
        self.setTitleViewFrame(withModel: self.historyModel!)
    }
    
    //MARK: 设置TitleView
    ///设置TitleView
    func setTitleViewFrame(withModel model:PTSegHistoryModel) {
        if model.systemContent.stringIsEmpty() {
            self.setTitleViewFrame(text: model.keyName)
        } else {
            let titleViewSapce = (CGFloat.kSCREEN_WIDTH - 34 - PTAppBaseConfig.share.defaultViewSpace * 2 - 20)

            let titleWidth = UIView.sizeFor(string: model.keyName, font: .appfont(size: 17), height: 44, width: CGFloat(MAXFLOAT)).width + 24 + 5 + 10
            let aiSetWidth = UIView.sizeFor(string: model.systemContent, font: .appfont(size: 14), height: 44, width: CGFloat(MAXFLOAT)).width + 24 + 5 + 10
            var contrast = titleWidth > aiSetWidth ? titleWidth : aiSetWidth
            if contrast >= titleViewSapce {
                contrast = titleViewSapce
            }
            self.titleButton.frame = CGRect(x: 0, y: 0, width: contrast, height: 34)
            if !Gobal_device_info.isPad {
                self.titleButton.isUserInteractionEnabled = true
                self.titleButton.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
            } else {
                self.titleButton.isUserInteractionEnabled = false
            }
            
            let att:ASAttributedString = """
            \(wrap: .embedding("""
            \("\(model.keyName)",.paragraph(.alignment(.center),.lineSpacing(5)),.foreground(.gobalTextColor),.font(.appfont(size: 17)))
            \("\(model.systemContent)",.paragraph(.alignment(.center),.lineSpacing(5)),.foreground(.lightGray),.font(.appfont(size: 14)))
            """),.paragraph(.alignment(.left)))
            """
            self.titleButton.setAttributedTitle(att.value, for: .normal)
        }
    }
    
    func setTitleViewFrame(text:String) {
        
        self.titleButton.setAttributedTitle(nil, for: .normal)
        if text == "Base" {
            self.titleButton.setTitle(kAppName!, for: .normal)
        } else {
            self.titleButton.setTitle(text, for: .normal)
        }
        
        if text == .thinking {
            var buttonW = self.titleButton.sizeFor(size: CGSize(width: CGFloat.kSCREEN_WIDTH - 108, height: 34)).width + 10
            let titleViewSapce = (CGFloat.kSCREEN_WIDTH - 34 - PTAppBaseConfig.share.defaultViewSpace * 2 - 20)
            if buttonW >= titleViewSapce {
                buttonW = titleViewSapce
            }
            self.titleButton.setImage(nil, for: .normal)
            self.titleButton.frame = CGRect(x: 0, y: 0, width: buttonW, height: 34)
            self.titleButton.isUserInteractionEnabled = false
        } else {
            var buttonW = self.titleButton.sizeFor(size: CGSize(width: CGFloat.kSCREEN_WIDTH - 108, height: 34)).width + 24 + 5 + 10
            let titleViewSapce = (CGFloat.kSCREEN_WIDTH - 34 - PTAppBaseConfig.share.defaultViewSpace * 2 - 20)
            if buttonW >= titleViewSapce {
                buttonW = titleViewSapce
            }
            self.titleButton.frame = CGRect(x: 0, y: 0, width: buttonW, height: 34)
            if !Gobal_device_info.isPad {
                self.titleButton.isUserInteractionEnabled = true
                self.titleButton.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
            } else {
                self.titleButton.isUserInteractionEnabled = false
            }
        }
    }

    @objc func loadMoreMessage() {
        self.refreshViewAndLoadNewData {
            DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func configureMessageCollectionView() {
//        messagesCollectionView.register(PTChatCustomCell.self)
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = .gobalBackgroundColor
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        showMessageTimestampOnSwipeLeft = true // default false

        messagesCollectionView.refreshControl = refreshControl
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    // MARK: - Helpers
    func insertMessage(_ message: PTMessageModel,refreshDone:(()->Void)? = nil) {
        messageList.append(message)
      // Reload last section to update header/footer labels and insert a new one
        PTGCDManager.gcdBackground {
            PTGCDManager.gcdMain {
                self.messagesCollectionView.performBatchUpdates({
                    self.messagesCollectionView.insertSections([self.messageList.count - 1])
                    if self.messageList.count >= 2 {
                        self.messagesCollectionView.reloadSections([self.messageList.count - 2])
                  }
                }, completion: { [weak self] _ in
                    if self?.isLastSectionVisible() == true {
                        self?.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                    
                    if self?.messageList.count == 1 {
                        self?.messagesCollectionView.reloadData()
                    } 
                    
                    PTGCDManager.gcdAfter(time: 0.35) {
                        if refreshDone != nil {
                            refreshDone!()
                        }
                    }
                })
            }
        }
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    func isLastSectionVisible() -> Bool {
      guard !messageList.isEmpty else { return false }

      let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    // MARK: Private
    // MARK: - Private properties
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    //MARK: 保存聊天記錄
    func packChatData() {
        var arr = AppDelegate.appDelegate()!.appConfig.tagDataArr()
        for (index,value) in arr.enumerated() {
            if value!.keyName == self.historyModel!.keyName {
                arr[index] = self.historyModel!
                break
            }
        }
        AppDelegate.appDelegate()!.appConfig.setChatData = arr.kj.JSONObjectArray()
    }
        
    func saveChatModelToJsonString(model:PTFavouriteModel) {
        
        var favourite = AppDelegate.appDelegate()!.appConfig.getSaveChatData()
        if favourite.count > 0 {
            favourite.append(model)
            AppDelegate.appDelegate()!.appConfig.favouriteChat = favourite.kj.JSONObjectArray()
        } else {
            AppDelegate.appDelegate()!.appConfig.favouriteChat = [model.kj.JSONObject()]
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            StatusBarManager.shared.style = UITraitCollection.current.userInterfaceStyle == .dark ? .lightContent : .darkContent
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func setTokenButton() {
        if self.tokenButton.isSelected {
            let money = AppDelegate.appDelegate()!.appConfig.totalTokenCost
            let moneyString = String(format: "%f", money)
            self.tokenButton.setTitle(moneyString, for: .normal)
        } else {
            let tokenString = String(format: "%.0f", AppDelegate.appDelegate()!.appConfig.totalToken)
            self.tokenButton.setTitle(tokenString, for: .normal)
        }
    }
}

//MARK: 键盘相关
///键盘相关
extension PTChatViewController {
    //MARK: KEYBOARD
    func baseInputBar() {
        messageInputBar.alpha = 1
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .gobalBackgroundColor
    }
    
    func configureMessageInputBar() {
        self.baseInputBar()
        messageInputBar.inputTextView.textColor = .gobalTextColor
        messageInputBar.inputTextView.tintColor = .gobalTextColor
        messageInputBar.sendButton.spacing = .fixed(10)
        messageInputBar.sendButton.setSize(CGSize(width: 52, height: 34), animated: true)
        messageInputBar.sendButton.setTitle(PTLanguage.share.text(forKey: "chat_Send"), for: .normal)
        messageInputBar.sendButton.setTitleColor( .gobalTextColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            .gobalTextColor.withAlphaComponent(0.3),
            for: .highlighted)
        
        self.setInputOtherItem()
    }
    
    func setSendVoiceInputBar() {
        self.baseInputBar()
        self.setInputOtherItem()
    }
    
    func setInputOtherItem() {
        self.messageInputBar.setStackViewItems([self.leftInputStackButton()], forStack: .left, animated: false)
        self.messageInputBar.setLeftStackViewWidthConstant(to: 34, animated: false)
        self.messageInputBar.setStackViewItems([self.rightInputStackButton,.flexibleSpace,self.messageInputBar.sendButton], forStack: .right, animated: false)
        self.messageInputBar.setRightStackViewWidthConstant(to: 96, animated: false)
        let bottomItems = [self.imageBarButton,self.textImageBarButton,self.inputBarChatSentence,self.tfImageButton,self.tagSuggestionButton, .flexibleSpace]
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        self.view.addSubviews([self.tokenButton,self.tokenCostButton])
        self.tokenButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalTo(24)
            make.bottom.equalTo(self.messageInputBar.snp.top).offset(-10)
            make.width.equalTo(UIView.sizeFor(string: "0.0000002", font: self.tokenButton.titleLabel!.font, height: 24, width: CGFloat(MAXFLOAT)).width + UIFont.appfont(size: 13).pointSize + 5 + 10)
        }
        
        self.tokenCostButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalTo(self.tokenButton.snp.right).offset(10)
            make.centerY.equalTo(self.tokenButton)
        }
    }
    
    func setEditInputItem() {
        self.messageInputBar.setStackViewItems([self.inputBarCloseEditButton], forStack: .top, animated: false)
        self.setInputOtherItem()
    }
        
    func cleanInputBarTop() {
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.messageInputBar.inputTextView.placeholder = "Aa"
        self.editMainImageButton.setImage(UIImage(systemName: "rectangle.stack.badge.plus")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        self.editMaskImageButton.setImage(UIImage(systemName: "rectangle.center.inset.filled.badge.plus")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        self.messageInputBar.setStackViewItems([], forStack: .top, animated: true)
    }
    
    func setEditImageBar() {
        self.messageInputBar.topStackView.backgroundColor = .gobalBackgroundColor
        self.messageInputBar.setStackViewItems([self.editCloseButton,self.editMainImageButton,self.editMaskImageButton], forStack: .top, animated: false)
        self.setInputOtherItem()
    }
        
    //MARK: 语音发送操作
    @objc func recordButtonPressed() {
        if self.avCaptureDeviceAuthorize(avMediaType: .audio) {
            self.messageInputBar.inputTextView.resignFirstResponder()
            self.maskView.visualizerView.start()
            self.soundRecorder.start()

            // 開始錄音
            self.isRecording = true
            PTNSLogConsole("開始錄音")
        }
    }
    
    @objc func recordButtonReleased() {
        if self.avCaptureDeviceAuthorize(avMediaType: .audio) {
            // 停止錄音
            self.isRecording = false
            PTNSLogConsole("停止錄音")
            self.speechKit.endVoiceRecording()
            self.soundRecorder.stop()
            self.maskView.visualizerView.stop()
            self.maskView.alpha = 0
        }
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if self.avCaptureDeviceAuthorize(avMediaType: .audio) {
            self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_end"), for: .normal)
            if self.isRecording {
                self.speechKit.recordVoice()
                self.isRecording = false
            }
            self.maskView.actionInfoLabel.isHidden = true
            self.maskView.actionInfoLabel.text = ""
            switch sender.state {
            case .began:
                // 開始錄音，顯示錄音的動畫和文字
                PTNSLogConsole("開始錄音，顯示錄音的動畫和文字")
                
                self.maskView.alpha = 1
                
            case .changed:
                let touchPoint = sender.location(in: self.voiceButton)
                if touchPoint.y < -(CGFloat.kTabbarHeight_Total + 34) {
                    PTNSLogConsole("超過閾值，顯示「向上取消」的提示")
                    let screenCenterX = (CGFloat.kSCREEN_WIDTH / 2)
                    let centerX = (screenCenterX - 44)
                    if touchPoint.x < centerX {
                        let newX = (touchPoint.x - centerX)
                        PTNSLogConsole(newX)
                        if abs(newX) >= (screenCenterX / 2) {
                            self.maskView.visualizerView.backgroundColor = .red
                            self.maskView.visualizerView.snp.updateConstraints { make in
                                make.width.equalTo(150)
                                make.centerX.equalToSuperview().offset(-(screenCenterX / 2))
                            }
                            self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_cancel"), for: .normal)
                            self.maskView.actionInfoLabel.isHidden = false
                            self.maskView.actionInfoLabel.text = PTLanguage.share.text(forKey: "voice_Cancel_send")
                        } else if abs(newX) <= 44 {
                            self.maskView.visualizerView.backgroundColor = self.maskView.visualizerViewBaseBackgroundColor
                            self.maskView.visualizerView.snp.updateConstraints { make in
                                make.centerX.equalToSuperview().offset(0)
                                make.width.equalTo(150)
                            }
                            self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_release"), for: .normal)
                            self.maskView.actionInfoLabel.isHidden = true
                            self.maskView.actionInfoLabel.text = ""
                        } else {
                            self.maskView.visualizerView.backgroundColor = .red
                            self.maskView.visualizerView.snp.updateConstraints { make in
                                make.centerX.equalToSuperview().offset(newX)
                                make.width.equalTo(150)
                            }
                            self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_cancel"), for: .normal)
                            self.maskView.actionInfoLabel.isHidden = false
                            self.maskView.actionInfoLabel.text = PTLanguage.share.text(forKey: "voice_Cancel_send")
                        }
                        PTNSLogConsole("在左边")
                        self.translateToText = false
                    } else if touchPoint.x > (screenCenterX + 44) {
                        self.translateToText = true
                        self.sendTranslateText = true
                        PTNSLogConsole("在右边")
                        self.maskView.visualizerView.snp.updateConstraints { make in
                            make.width.equalTo(CGFloat.kSCREEN_WIDTH - 40)
                        }
                        self.maskView.actionInfoLabel.isHidden = false
                        self.maskView.actionInfoLabel.text = PTLanguage.share.text(forKey: "voice_Change_to_text")
                    } else {
                        self.translateToText = false
                        PTNSLogConsole("在中间")
                        self.maskView.visualizerView.snp.updateConstraints { make in
                            make.centerX.equalToSuperview().offset(0)
                            make.width.equalTo(150)
                        }
                        self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_release"), for: .normal)
                        self.maskView.actionInfoLabel.isHidden = true
                        self.maskView.actionInfoLabel.text = ""
                    }
                    // 超過閾值，顯示「向上取消」的提示
                } else {
                    // 未超過閾值，顯示「鬆開發送」的提示
                    self.translateToText = false
                    PTNSLogConsole("未超過閾值，顯示「鬆開發送」的提示")
                    self.maskView.visualizerView.snp.updateConstraints { make in
                        make.centerX.equalToSuperview().offset(0)
                    }
                    self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_release"), for: .normal)
                }
            case .ended:
                self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap"), for: .normal)
                let touchPoint = sender.location(in: self.voiceButton)
                if touchPoint.y < -(CGFloat.kTabbarHeight_Total + 34) {
                    let screenCenterX = (CGFloat.kSCREEN_WIDTH / 2)
                    let centerX = (screenCenterX - 44)
                    if touchPoint.x < centerX {
                        let newX = (touchPoint.x - centerX)
                        PTNSLogConsole(newX)
                        if abs(newX) >= (screenCenterX / 2) {
                            self.isSendVoice = false
                        } else if abs(newX) <= 44 {
                            self.isSendVoice = true
                        } else {
                            self.isSendVoice = false
                        }
                        PTNSLogConsole("在左边")
                    } else if touchPoint.x > (screenCenterX + 44) {
                        self.isSendVoice = true
                    } else {
                        self.isSendVoice = true
                    }
                } else {
                    self.isSendVoice = true
                }
                self.isRecording = false
                PTGCDManager.gcdMain {
                    self.speechKit.endVoiceRecording()
                    self.translateToText = false
                    self.soundRecorder.stop()
                    self.maskView.visualizerView.stop()
                    self.maskView.alpha = 0
                    self.maskView.visualizerView.backgroundColor = self.maskView.visualizerViewBaseBackgroundColor
                    self.maskView.visualizerView.snp.updateConstraints { make in
                        make.centerX.equalToSuperview().offset(0)
                        make.width.equalTo(150)
                    }
                }
            default:
                break
            }
        }
    }
}

// MARK: - MessagesDisplayDelegate
extension PTChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    //MARK: 文字顏色
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? AppDelegate.appDelegate()!.appConfig.userTextColor : AppDelegate.appDelegate()!.appConfig.botTextColor
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    //MARK: 設置Bubble顏色
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? AppDelegate.appDelegate()!.appConfig.userBubbleColor : AppDelegate.appDelegate()!.appConfig.botBubbleColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = PTChatData.share.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.kf.cancelDownloadTask()
        }
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for _: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) {
      // Cells are reused, so only add a button here once. For real use you would need to
      // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        
        let cellModel = self.messageList[indexPath.section]
        if cellModel.sending! {
            return
        }
        
        if cellModel.sendSuccess {
            return
        }
        let button = UIButton(type: .infoLight)
        button.tintColor = .red
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Audio Messages
    //MARK: 語音文字顏色
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        self.audioPlayer.configureAudioCell(cell, message: message)
    }
}

//MARK: MessagesLayoutDelegate
extension PTChatViewController:MessagesLayoutDelegate {
//    func textCellSizeCalculator( for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CellSizeCalculator? {
//            textMessageSizeCalculator
//    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let dateString = formatter.string(from: message.sentDate)
        let messageModel = self.messageList[indexPath.section]
        
        var dateHeight = UIView.sizeFor(string: dateString, font: UIFont.preferredFont(forTextStyle: .caption2), lineSpacing: 4, height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH).height
        if dateHeight < 16 {
            dateHeight = 16
        }
        
        var editHeight:CGFloat = 0
        if !messageModel.correctionText.nsString.stringIsEmpty() {
            editHeight = UIView.sizeFor(string: messageModel.correctionText, font: UIFont.preferredFont(forTextStyle: .caption2), lineSpacing: 4, height: CGFloat(MAXFLOAT), width: CGFloat.kSCREEN_WIDTH).height
            
            if editHeight < 16 {
                editHeight = 16
            }
        }
        return (dateHeight + editHeight)
    }
}

//MARK: MessagesDataSource
extension PTChatViewController:MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return PTChatData.share.user
    }
        
    func numberOfSections(in _: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      if indexPath.section % 3 == 0 {
        return NSAttributedString(
          string: MessageKitDateFormatter.shared.string(from: message.sentDate),
          attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
          ])
      }
      return nil
    }

    func cellBottomLabelAttributedText(for _: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      let cellModel = self.messageList[indexPath.section]

        var sendString = ""
        if cellModel.sending! {
            sendString = PTLanguage.share.text(forKey: "chat_Sending")
        } else {
            sendString = cellModel.sendSuccess ? PTLanguage.share.text(forKey: "chat_Read") : PTLanguage.share.text(forKey: "chat_Send_error")
        }
        
      return NSAttributedString(
        string: sendString ,
        attributes: [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
          NSAttributedString.Key.foregroundColor: UIColor.darkGray,
        ])
    }

    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),NSAttributedString.Key.foregroundColor:UIColor.gobalTextColor])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        let messageModel = self.messageList[indexPath.section]
                
        var totalAtt:ASAttributedString = ASAttributedString("")
        let attMain:ASAttributedString = """
        \(wrap: .embedding("""
        \("\(dateString)",.paragraph(.alignment((message.sender.senderId == PTChatData.share.bot.senderId ? .left : .right)),.lineSpacing(4)),.foreground(.gobalTextColor),.font(UIFont.preferredFont(forTextStyle: .caption2)))
        """))
        """
        totalAtt += attMain
        if !messageModel.correctionText.nsString.stringIsEmpty() {
            let attEdit:ASAttributedString = """
            \(wrap: .embedding("""
            \("\((PTLanguage.share.text(forKey: "chat_Edit_message") + messageModel.correctionText))",.paragraph(.alignment(.left),.lineSpacing(4)),.foreground(.gobalTextColor),.font(UIFont.preferredFont(forTextStyle: .caption2)),.background(.black.withAlphaComponent(0.05))))
            """))
            """
            totalAtt += attEdit
        }
        return totalAtt.value
    }

    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
//
//        let cell = messagesCollectionView.dequeueReusableCell( PTChatCustomCell.self, for: indexPath)
//        cell.configure( with: message, at: indexPath, in: messagesCollectionView, dataSource: self, and: textMessageSizeCalculator)
        return nil
    }
    
}

//MARK: MessageCellDelegate
extension PTChatViewController:MessageCellDelegate {
    func didTapBackground(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("didTapBackground")
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("Avatar tapped")
        if !self.onlyShowSave {
            let indexPath = self.messagesCollectionView.indexPath(for: cell)
            let messageModel = self.messageList[indexPath?.section ?? 0]
            var vc:PTSettingListViewController!
            if messageModel.sender.senderId == PTChatData.share.bot.senderId {
                vc = PTSettingListViewController(user: PTChatData.share.bot)
                vc.currentChatModel = self.historyModel
            } else {
                vc = PTSettingListViewController(user: PTChatData.share.user)
            }
            self.navigationController?.pushViewController(vc)
        }
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("didTapMessage")

        self.messageInputBar.inputTextView.resignFirstResponder()
        
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        let messageModel = self.messageList[indexPath!.section]

        var titles:[String] = [String]()
        switch messageModel.kind {
        case .text( _):
            if messageModel.sender.senderId == PTChatData.share.bot.senderId {
                if self.onlyShowSave {
                    titles = [.copyString,.playString]
                } else {
                    titles = [.copyString,.editString,.playString,.saveString]
                }
            } else {
                if self.onlyShowSave {
                    titles = [.copyString]
                } else {
                    titles = [.copyString,.editString]
                }
            }
            
            self.messageInputBar.alpha = 0
            UIAlertController.baseActionSheet(title: PTLanguage.share.text(forKey: "alert_Option_title"), subTitle: PTLanguage.share.text(forKey: "alert_Select_option"),cancelButtonName: PTLanguage.share.text(forKey: "button_Cancel"), titles: titles) { sheet in
                
            } cancelBlock: { sheet in
                if !self.onlyShowSave {
                    self.messageInputBar.alpha = 1
                }
            } otherBlock: { sheet, index in
                if !self.onlyShowSave {
                    self.messageInputBar.alpha = 1
                }
                switch titles[index] {
                case .resend:
                    switch messageModel.kind {
                    case .text(let text):
                        self.insertMessages([text])
                    default: break
                    }
                case .copyString:
                    switch messageModel.kind {
                    case .text(let text):
                        text.copyToPasteboard()
                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Copy_done"))
                    default: break
                    }
                case .editString:                    
                    switch messageModel.kind {
                    case .text(let text):
                        self.chatCase = .chat(type: .edit)
                        self.editString = text
                        self.inputBarCloseEditButton.setTitle(text, for: .normal)
                        var textHeight = self.inputBarCloseEditButton.sizeFor(size: CGSize(width: CGFloat.kSCREEN_WIDTH, height: CGFloat(MAXFLOAT))).height
                        if textHeight <= 44 {
                            textHeight = 44
                        }
                        self.inputBarCloseEditButton.setSize(CGSize(width: CGFloat.kSCREEN_WIDTH, height: textHeight), animated: true)
                        self.setEditInputItem()
                        PTGCDManager.gcdAfter(time: 1) {
                            self.messageInputBar.inputTextView.placeholder = PTLanguage.share.text(forKey: "chat_Edit")
                        }
                        self.messageInputBar.inputTextView.becomeFirstResponder()
                    default: break
                    }
                case .playString:
                    switch messageModel.kind {
                    case .text(let text):
                        if messageModel.sender.senderId == PTChatData.share.bot.senderId {
                            self.speechKit.speakText(text)
                        }
                    default: break
                    }
                case .saveString:
                    PTGCDManager.gcdAfter(time: 0.5) {
                        if messageModel.sender.senderId == PTChatData.share.bot.senderId {
                            let userModel = self.messageList[indexPath!.section - 1]
                            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_Save_Q&A"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                                
                            } moreBtn: { index, title in
                                let model = PTChatModel()
                                
                                switch userModel.kind {
                                case .audio(let item):
                                    model.messageType = 1
                                    model.messageMediaURL = item.url.lastPathComponent
                                    self.speechKit.recognizeSpeech(filePath: URL(fileURLWithPath: item.url.absoluteString.replacingOccurrences(of: "file://", with: ""))) { text in
                                        model.messageText = text
                                    }
                                case .text(let text):
                                    model.messageType = 0
                                    model.messageText = text
                                default:
                                    break
                                }
                                model.messageDateString = userModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                
                                let botMessage = PTChatModel()
                                switch messageModel.kind {
                                case .photo(let item):
                                    botMessage.messageType = 1
                                    botMessage.messageMediaURL = item.url!.absoluteString
                                case .text(let text):
                                    botMessage.messageType = 0
                                    botMessage.messageText = text
                                    botMessage.outgoing = false
                                    botMessage.messageDateString = messageModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                default:
                                    break
                                }
                                let favouriteModel = PTFavouriteModel()
                                favouriteModel.chatContent = model.messageText.stringIsEmpty() ? "Voice" : model.messageText
                                favouriteModel.chats = [model,botMessage]
                                self.saveChatModelToJsonString(model: favouriteModel)
                                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_success"))
                            }
                        }
                    }
                default:
                    break
                }
            } tapBackgroundBlock: { sheet in
                if !self.onlyShowSave {
                    self.messageInputBar.alpha = 1
                }
            }
        case .attributedText(_):
            let hisModel = self.historyModel!.historyModel[indexPath!.section]
            
            var viewModels = [PTViewerModel]()
            
            if !hisModel.editMainName.stringIsEmpty() {
                let viewerModel = PTViewerModel()
                viewerModel.imageURL = AppDelegate.appDelegate()!.appConfig.getMessageImage(name: hisModel.editMainName)
                viewerModel.imageShowType = .Normal
                viewModels.append(viewerModel)
            }
            
            if !hisModel.editMaskName.stringIsEmpty() {
                let viewerModel = PTViewerModel()
                viewerModel.imageURL = AppDelegate.appDelegate()!.appConfig.getMessageImage(name: hisModel.editMaskName)
                viewerModel.imageShowType = .Normal
                viewModels.append(viewerModel)
            }

            let config = PTViewerConfig()
            config.actionType = .Empty
            config.closeViewerImage = UIImage(systemName: "chevron.left")!.withTintColor(.white, renderingMode: .automatic)
            config.moreActionImage = UIImage(systemName: "ellipsis")!.withRenderingMode(.automatic)
            config.mediaData = viewModels
            
            let viewer = PTMediaViewer(viewConfig: config)
            viewer.showImageViewer()

        default:
            break
        }
    }

    func didTapImage(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("Image tapped")
        self.messageInputBar.inputTextView.resignFirstResponder()
        
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        let messageModel = self.messageList[indexPath!.section]
        switch messageModel.kind {
        case .photo(let image):
            PTNSLogConsole(image)
            self.messageInputBar.alpha = 0
            let viewerModel = PTViewerModel()
            viewerModel.imageURL = image.url?.absoluteString
            viewerModel.imageShowType = .Normal
            let config = PTViewerConfig()
            config.actionType = .Save
            config.closeViewerImage = UIImage(systemName: "chevron.left")!.withTintColor(.white, renderingMode: .automatic)
            config.moreActionImage = UIImage(systemName: "ellipsis")!.withRenderingMode(.automatic)
            config.mediaData = [viewerModel]
            config.moreActionEX = AppDelegate.appDelegate()!.appConfig.imageControlActions
            config.iCloudDocumentName = "Documents"
            let viewer = PTMediaViewer(viewConfig: config)
            viewer.showImageViewer()
            viewer.viewSaveImageBlock = { finish in
                if finish {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_success"))
                }
            }
            viewer.viewMoreActionBlock = { index in
                self.messageInputBar.alpha = 1
                PTNSLogConsole("\(image.image as Any)\\\\.\(String(describing: image.url))")
                ImageDownloader.default.downloadImage(with: image.url!, options: PTAppBaseConfig.share.gobalWebImageLoadOption()) { result in
                    switch result {
                    case .success(let value):
                        switch AppDelegate.appDelegate()!.appConfig.imageControlActions[index] {
                        case .remakeImage:
                            self.chatCase = .draw(type: .edit)
                            self.setEditImageBar()
                            self.editMainImageButton.setImage(value.image, for: .normal)
                        case .findImage:
                            let date = Date()

                            let saveModel = PTChatModel()
                            saveModel.messageType = 2
                            saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                            saveModel.messageSendSuccess = false
                            saveModel.messageMediaURL = image.url!.absoluteString

                            var message = PTMessageModel(imageURL: image.url!, user: PTChatData.share.user, messageId: UUID().uuidString, date: date,sendSuccess: false)
                            message.sending = true
                            self.insertMessage(message) {
                                self.messageList[(self.messageList.count - 1)].sending = true
                                self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                    PTNSLogConsole("开始发送")
                                    self.userSendImage(imageObject: value.image, saveModel: saveModel)
                                }
                            }
                        default:
                            break
                        }
                    case .failure(let error):
                        PTNSLogConsole(error.localizedDescription)
                    }
                }
            }
            viewer.viewerDismissBlock = {
                self.messageInputBar.alpha = 1
            }

        default:
            break
        }
    }

    func didTapCellTopLabel(in _: MessageCollectionViewCell) {
        PTNSLogConsole("Top cell label tapped")
    }

    func didTapCellBottomLabel(in _: MessageCollectionViewCell) {
        PTNSLogConsole("Bottom cell label tapped")
    }

    func didTapMessageTopLabel(in _: MessageCollectionViewCell) {
        PTNSLogConsole("Top message label tapped")
    }

    func didTapMessageBottomLabel(in _: MessageCollectionViewCell) {
        PTNSLogConsole("Bottom label tapped")
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else {
            PTNSLogConsole("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioPlayer.state != .stopped else {
            self.audioPlayer.playSound(for: message, in: cell)
            return
        }
        if self.audioPlayer.playingMessage?.messageId == message.messageId {
            if self.audioPlayer.state == .playing {
                self.audioPlayer.pauseSound(for: message, in: cell)
            } else {
                self.audioPlayer.resumeSound()
            }
        } else {
            self.audioPlayer.stopAnyOngoingPlaying()
            self.audioPlayer.playSound(for: message, in: cell)
        }
    }

    func didStartAudio(in _: AudioMessageCell) {
        PTNSLogConsole("Did start playing audio sound")
    }

    func didPauseAudio(in _: AudioMessageCell) {
        PTNSLogConsole("Did pause audio sound")
    }

    func didStopAudio(in _: AudioMessageCell) {
        PTNSLogConsole("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("Accessory view tapped")
        self.messageInputBar.inputTextView.resignFirstResponder()
        
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        var messageModel = self.messageList[indexPath!.section]
        
        for ( _ ,value) in self.chatModels.enumerated() {
            if value.messageDateString == messageModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss") {
                self.setTypingIndicatorViewHidden(false)
                let date = Date()
                let saveModel = value
                saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                messageModel.sending = true
                messageModel.sendSuccess = false
                messageModel.sentDate = date
                if !messageModel.correctionText.stringIsEmpty() {
                    self.chatCase = .chat(type: .edit)
                }
                self.messageList.remove(at: indexPath!.section)
                self.messageList.append(messageModel)
                self.chatModels.remove(at: indexPath!.section)
                self.chatModels.append(saveModel)
                self.historyModel?.historyModel = self.chatModels
                self.refreshViewAndLoadNewData {
                    self.messageList[(self.messageList.count - 1)].sending = true
                    self.messageList[(self.messageList.count - 1)].sendSuccess = false
                    self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                        switch messageModel.kind {
                        case .text(let text):
                            self.checkSentence(checkWork: text) { useCheckApi, isFlagged, error in
                                if useCheckApi {
                                    if isFlagged {
                                        self.sendTextFunction(str: text, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),resend: true,flagType: .YES)
                                    } else {
                                        if error != nil {
                                            self.messageList[(self.messageList.count - 1)].sending = false
                                            self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                            self.chatModels[self.chatModels.count - 1].messageSendSuccess = false
                                            self.reloadSomeSection(itemIndex: (self.messageList.count - 1))
                                            self.historyModel?.historyModel = self.chatModels
                                            self.packChatData()
                                            PTGCDManager.gcdMain {
                                                self.setTypingIndicatorViewHidden(true)
                                                self.refreshViewAndLoadNewData()
                                                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                            }
                                        } else {
                                            self.messageList[(self.messageList.count - 1)].kind = .text(text.replaceStringWithAsterisk())
                                            self.messageList[(self.messageList.count - 1)].sendSuccess = true
                                            self.chatModels[self.chatModels.count - 1].starString = text.replaceStringWithAsterisk()
                                            self.chatModels[self.chatModels.count - 1].messageSendSuccess = true
                                            PTGCDManager.gcdMain {
                                                self.setTypingIndicatorViewHidden(true)
                                                self.notGoodWordRequest()
                                            }
                                        }
                                    }
                                } else {
                                    self.sendTextFunction(str: text, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),resend: true,flagType: .PASS)
                                }
                            }
                        case .attributedText(_):
                            self.checkSentence(checkWork: saveModel.messageText) { useCheckApi, isFlagged, error in
                                if useCheckApi {
                                    if isFlagged {
                                        self.userEditImage(str: saveModel.messageText, saveModel: saveModel,resend: true)
                                    } else {
                                        if error != nil {
                                            self.messageList[(self.messageList.count - 1)].sending = false
                                            self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                            self.chatModels[self.chatModels.count - 1].messageSendSuccess = false
                                            self.reloadSomeSection(itemIndex: (self.messageList.count - 1))
                                            self.historyModel?.historyModel = self.chatModels
                                            self.packChatData()
                                            PTGCDManager.gcdMain {
                                                self.setTypingIndicatorViewHidden(true)
                                                self.refreshViewAndLoadNewData()
                                                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                            }
                                        } else {
                                            var total:ASAttributedString = ASAttributedString("")

                                            let attMain:ASAttributedString = """
                                            \(wrap: .embedding("""
                                            \("\(saveModel.messageText.replaceStringWithAsterisk())",.foreground(AppDelegate.appDelegate()!.appConfig.userTextColor))
                                            \(.image(AppDelegate.appDelegate()!.appConfig.getMessageImage(name: saveModel.editMainName),.custom(size:.init(width:100,height:100))))
                                            """))
                                            """
                                            total += attMain
                                            if !saveModel.editMaskName.stringIsEmpty() {
                                                let attMask:ASAttributedString = """
                                                \(wrap: .embedding("""
                                                \(.image(AppDelegate.appDelegate()!.appConfig.getMessageImage(name: saveModel.editMaskName),.custom(size:.init(width:100,height:100))))
                                                """))
                                                """
                                                total += attMask
                                            }

                                            self.messageList[(self.messageList.count - 1)].kind = .attributedText(total.value)
                                            self.messageList[(self.messageList.count - 1)].sendSuccess = true
                                            self.chatModels[self.chatModels.count - 1].starString = saveModel.messageText.replaceStringWithAsterisk()
                                            self.chatModels[self.chatModels.count - 1].messageSendSuccess = true
                                            PTGCDManager.gcdMain {
                                                self.setTypingIndicatorViewHidden(true)
                                                self.notGoodWordRequest()
                                            }
                                        }
                                    }
                                } else {
                                    self.userEditImage(str: saveModel.messageText, saveModel: saveModel,resend: true)
                                }
                            }
                        case .audio(_):
                            self.sendTextFunction(str: saveModel.messageText, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),resend: true,flagType: .PASS)
                        case .photo(_):
                            self.userSendImage(imageObject: AppDelegate.appDelegate()!.appConfig.getMessageImage(name: saveModel.localFileName), saveModel: saveModel,resend: true)
                        default:
                            break
                        }
                    }
                }
                break
            }
        }
    }
}

extension PTChatViewController: MessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        PTNSLogConsole("Address Selected: \(addressComponents)")
    }

    func didSelectDate(_ date: Date) {
        PTNSLogConsole("Date Selected: \(date)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        PTNSLogConsole("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        PTNSLogConsole("URL Selected: \(url)")
    }

    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        PTNSLogConsole("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        PTNSLogConsole("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        PTNSLogConsole("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match _: String?) {
        PTNSLogConsole("Custom data detector patter selected: \(pattern)")
    }
}


extension PTChatViewController: InputBarAccessoryViewDelegate {
    func drawImage(str:String,saveModel:PTChatModel,indexSection:Int,resend:Bool? = false) {
        var imageSizeType:PTOpenAIImageSize
        switch AppDelegate.appDelegate()!.appConfig.aiDrawSize.width {
        case 1024:
            imageSizeType = .size1024
        case 512:
            imageSizeType = .size512
        case 256:
            imageSizeType = .size256
        default:
            imageSizeType = .size256
        }
        
        self.apiShare.imageGenerations(prompt: str,numberofImages: AppDelegate.appDelegate()!.appConfig.getImageCount, imageSize: imageSizeType) { model, error in
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    self.setTypingIndicatorViewHidden(true)
                }
            }
            if error != nil {
                PTGCDManager.gcdBackground {
                    PTGCDManager.gcdMain {
                        saveModel.messageSendSuccess = false
                        if resend! {
                            self.chatModels[indexSection] = saveModel
                        } else {
                            self.chatModels.append(saveModel)
                        }
                        self.historyModel?.historyModel = self.chatModels
                        self.refreshViewAndLoadNewData {
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    self.messageList[indexSection].sending = false
                                    self.messageList[indexSection].sendSuccess = false
                                    self.reloadSomeSection(itemIndex: indexSection) {
                                        self.packChatData()
                                        PTGCDManager.gcdMain {
                                            PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                saveModel.messageSendSuccess = true
                self.chatModels.append(saveModel)
                self.messageList[indexSection].sending = false
                self.messageList[indexSection].sendSuccess = true
                PTGCDManager.gcdBackground {
                    PTGCDManager.gcdMain {
                        self.reloadSomeSection(itemIndex: indexSection) {
                            self.receivedImage(urlArr: model!.data!, saveModel: saveModel, sendIndex: (self.messageList.count - 1))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Internal
    @objc func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        switch self.chatCase {
        case .draw(type: .edit):
            if self.editMainImageButton.imageView?.image == UIImage(systemName: "rectangle.stack.badge.plus")?.withTintColor(.black, renderingMode: .automatic) {
                PTBaseViewController.gobal_drop(title: "请选择需要修改的图片")
            } else {
                self.processInputBar(self.messageInputBar)
            }
        default:
            self.processInputBar(self.messageInputBar)
        }
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            PTNSLogConsole("Autocompleted:\(substring) with context\(String(describing: context))")
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = PTLanguage.share.text(forKey: "chat_Sending")
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async {
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self.insertMessages(components)
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    // MARK: Private
    //MARK: 绿色标语反馈创建
    private func notGoodWordRequest() {
        PTGCDManager.gcdMain {
            self.setTypingIndicatorViewHidden(true)
        }
        let botDate = Date()
        let botMessageModel = PTChatModel()
        botMessageModel.messageDateString = botDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        botMessageModel.messageType = 0
        botMessageModel.messageText = PTLanguage.share.text(forKey: "chat_Check_sentence")
        botMessageModel.outgoing = false
        self.chatModels.append(botMessageModel)

        var botMessage = PTMessageModel(text: PTLanguage.share.text(forKey: "chat_Check_sentence"), user: PTChatData.share.bot, messageId: UUID().uuidString, date: botDate)
        botMessage.sending = false
        PTGCDManager.gcdMain {
            self.insertMessage(botMessage) {
                self.historyModel?.historyModel = self.chatModels
                self.packChatData()
                self.refreshViewAndLoadNewData()
            }
        }
    }
    
    func insertMessages(_ data: [Any]) {
        for component in data {
            let user = PTChatData.share.user
            let date = Date()
            if let str = component as? String {
                let saveModel = PTChatModel()
                saveModel.messageType = 0
                saveModel.messageText = str
                saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                saveModel.messageSendSuccess = false
                switch self.chatCase {
                case .chat(type: .edit):
                    saveModel.correctionText = self.editString
                default:break
                    
                }
                var message = PTMessageModel(text: str, user: user, messageId: UUID().uuidString, date: date,correctionText:saveModel.correctionText)
                message.sending = true
                
                switch self.chatCase {
                case .draw(type: .edit):
                    self.mainImage = self.editMainImageButton.imageView!.image
                    if self.editMaskImageButton.imageView!.image == UIImage(systemName: "rectangle.center.inset.filled.badge.plus")?.withTintColor(.black, renderingMode: .automatic) {
                        self.maskImage = nil
                    } else {
                        self.maskImage = self.editMaskImageButton.imageView!.image
                    }
                    self.cleanInputBarTop()
                default:
                    break
                }
                
                self.checkSentence(checkWork: str) { useCheckApi, isFlagged, error in
                    if useCheckApi {
                        if isFlagged {
                            PTNSLogConsole("讲粗口:YES")
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    switch self.chatCase {
                                    case .draw(type: .edit):
                                        self.attMessageSend(date: date, saveModel: saveModel, str: str,isFlagged: .YES, error: nil,sendToServices: false)
                                    default:
                                        message.kind = .text(str.replaceStringWithAsterisk())
                                        message.sendSuccess = true
                                        saveModel.starString = str.replaceStringWithAsterisk()
                                        saveModel.messageSendSuccess = true
                                        self.chatModels.append(saveModel)
                                        PTGCDManager.gcdMain {
                                            self.insertMessage(message) {
                                                PTGCDManager.gcdMain {
                                                    self.setTypingIndicatorViewHidden(false)
                                                }
                                                self.notGoodWordRequest()
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            PTNSLogConsole("讲粗口:NO")
                            if error != nil {
                                switch self.chatCase {
                                case .draw(type: .edit):
                                    self.attMessageSend(date: date, saveModel: saveModel, str: str,isFlagged: .NO, error: error!,sendToServices: false)
                                default:
                                    self.insertMessage(message) {
                                        PTGCDManager.gcdMain {
                                            saveModel.messageSendSuccess = false
                                            self.chatModels.append(saveModel)
                                            self.historyModel?.historyModel = self.chatModels
                                            self.refreshViewAndLoadNewData {
                                                self.messageList[(self.messageList.count - 1)].sending = false
                                                self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                                self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                                    self.packChatData()
                                                    PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                switch self.chatCase {
                                case .draw(type: .edit):
                                    self.sendTextFunction(str: str, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),flagType: .NO)
                                default:
                                    PTGCDManager.gcdBackground {
                                        PTGCDManager.gcdMain {
                                            self.insertMessage(message) {
                                                self.sendTextFunction(str: str, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),flagType: .NO)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        PTNSLogConsole("讲粗口:PASS")
                        switch self.chatCase {
                        case .draw(type: .edit):
                            PTNSLogConsole("<<<<<<<<<><<<>>>>>>>><<\(str)")
                            self.sendTextFunction(str: str, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),flagType: .PASS)
                        default:
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    self.insertMessage(message) {
                                        self.sendTextFunction(str: str, saveModel: saveModel, sectionIndex: (self.messageList.count - 1),flagType: .PASS)
                                    }
                                }
                            }
                        }
                    }
                }
            } else if let img = component as? UIImage {
                let message = PTMessageModel(image: img, user: user, messageId: UUID().uuidString, date: Date(),sendSuccess: true)
                insertMessage(message)
            }
        }
    }
    
    func attMessageSend (date:Date,saveModel:PTChatModel,str:String,isFlagged:ChatIsFlag,error:AFError?,sendToServices:Bool) {
        self.chatCase = .chat(type: .normal)
        let dateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        let mainName = "main_\(dateString).png"
        let maskName = "mask_\(dateString).png"

        AppDelegate.appDelegate()!.appConfig.saveUserSendImage(image: self.mainImage!, fileName: mainName) { finish in
            if finish {
                if self.maskImage != nil {
                    PTGCDManager.gcdMain {
                        AppDelegate.appDelegate()!.appConfig.saveUserSendImage(image: self.maskImage!, fileName: maskName) { finish in
                            if finish {
                                PTGCDManager.gcdMain {
                                    saveModel.messageType = 0
                                    saveModel.messageSendSuccess = true
                                    saveModel.messageText = str
                                    saveModel.editMainName = mainName
                                    saveModel.editMaskName = maskName
                                    switch isFlagged {
                                    case .YES:
                                        saveModel.starString = str.replaceStringWithAsterisk()
                                    default:
                                        saveModel.starString = ""
                                    }

                                    let attMain:ASAttributedString = """
                                    \(wrap: .embedding("""
                                    \("\(!saveModel.starString.stringIsEmpty() ? str.replaceStringWithAsterisk() : str)",.foreground(AppDelegate.appDelegate()!.appConfig.userTextColor))
                                    \(.image(self.mainImage!,.custom(size:.init(width:100,height:100))))\(.image(self.maskImage!,.custom(size:.init(width:100,height:100))))

                                    """))
                                    """
                                    self.mainImage = nil
                                    self.maskImage = nil
                                    
                                    var message = PTMessageModel(attributedText: attMain.value, user: PTChatData.share.user, messageId: UUID().uuidString, date: date, sendSuccess: true)
                                    message.sending = true
                                    PTGCDManager.gcdMain {
                                        self.insertMessage(message) {
                                            if sendToServices {
                                                self.chatModels.append(saveModel)
                                                self.messageList[(self.messageList.count - 1)].sending = true
                                                self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                                self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                                    PTNSLogConsole("开始发送")
                                                    self.userEditImage(str: str, saveModel: saveModel)
                                                }
                                            } else {
                                                if error == nil {
                                                    self.chatModels.append(saveModel)
                                                    PTGCDManager.gcdMain {
                                                        self.setTypingIndicatorViewHidden(false)
                                                    }
                                                    self.notGoodWordRequest()
                                                } else {
                                                    PTGCDManager.gcdMain {
                                                        self.setTypingIndicatorViewHidden(true)
                                                    }
                                                    saveModel.messageSendSuccess = false
                                                    self.chatModels.append(saveModel)
                                                    self.historyModel?.historyModel = self.chatModels
                                                    self.packChatData()
                                                    self.messageList[(self.messageList.count - 1)].sending = false
                                                    self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                                    self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                                        self.refreshViewAndLoadNewData() {
                                                            PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    PTGCDManager.gcdMain {
                        saveModel.messageType = 0
                        saveModel.messageSendSuccess = true
                        saveModel.messageText = str
                        saveModel.editMainName = mainName
                        switch isFlagged {
                        case .YES:
                            saveModel.starString = str.replaceStringWithAsterisk()
                        default:
                            saveModel.starString = ""
                        }
                        self.chatModels.append(saveModel)
                        

                        let attMain:ASAttributedString = """
                        \(wrap: .embedding("""
                        \("\(str.replaceStringWithAsterisk())",.foreground(AppDelegate.appDelegate()!.appConfig.userTextColor))
                        \(.image(self.mainImage!,.custom(size:.init(width:100,height:100))))
                        """))
                        """
                        
                        self.mainImage = nil
                        self.maskImage = nil
                        
                        var message = PTMessageModel(attributedText: attMain.value, user: PTChatData.share.user, messageId: UUID().uuidString, date: date, sendSuccess: true)
                        message.sending = true
                        PTGCDManager.gcdMain {
                            self.insertMessage(message) {
                                if sendToServices {
                                    self.messageList[(self.messageList.count - 1)].sending = true
                                    self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                    self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                        PTNSLogConsole("开始发送")
                                        self.userEditImage(str: str, saveModel: saveModel)
                                    }
                                } else {
                                    if error == nil {
                                        PTGCDManager.gcdMain {
                                            self.setTypingIndicatorViewHidden(false)
                                        }
                                        self.notGoodWordRequest()
                                    } else {
                                        PTGCDManager.gcdMain {
                                            self.setTypingIndicatorViewHidden(true)
                                        }
                                        saveModel.messageSendSuccess = false
                                        self.chatModels.append(saveModel)
                                        self.historyModel?.historyModel = self.chatModels
                                        self.packChatData()
                                        self.messageList[(self.messageList.count - 1)].sending = false
                                        self.messageList[(self.messageList.count - 1)].sendSuccess = false
                                        self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                                            self.refreshViewAndLoadNewData() {
                                                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reloadSomeSection(itemIndex:Int,endBlock:(()->Void)? = nil) {
        self.messagesCollectionView.reloadSections(IndexSet(integer: itemIndex))
        PTGCDManager.gcdAfter(time: 0.35) {
            if endBlock != nil {
                endBlock!()
            }
        }
    }
    
    func userEditImage(str:String,saveModel:PTChatModel,resend:Bool? = false) {
        self.setTypingIndicatorViewHidden(false)
        var imageSizeType:PTOpenAIImageSize
        switch AppDelegate.appDelegate()!.appConfig.aiDrawSize.width {
        case 1024:
            imageSizeType = .size1024
        case 512:
            imageSizeType = .size512
        case 256:
            imageSizeType = .size256
        default:
            imageSizeType = .size256
        }
        
        var maskImage:UIImage?
        if saveModel.editMaskName.stringIsEmpty() {
            maskImage = nil
        } else {
            maskImage = AppDelegate.appDelegate()!.appConfig.getMessageImage(name: "\(saveModel.editMaskName)")
        }
        
        self.apiShare.editImage(prompt: str, mainImage: AppDelegate.appDelegate()!.appConfig.getMessageImage(name: "\(saveModel.editMainName)"), maskImage: maskImage, imageSize: imageSizeType) { model, error in
            if error == nil {
                self.messageList[(self.messageList.count - 1)].sending = false
                self.messageList[(self.messageList.count - 1)].sendSuccess = true
                self.receivedImage(urlArr: model!.data!, saveModel: saveModel, sendIndex: (self.messageList.count - 1))
            } else {
                PTNSLogConsole(error!.localizedDescription)
                PTGCDManager.gcdMain {
                    self.setTypingIndicatorViewHidden(true)
                    saveModel.messageSendSuccess = false
                    self.chatModels[self.chatModels.count - 1] = saveModel

                    self.historyModel?.historyModel = self.chatModels
                    self.refreshViewAndLoadNewData {
                        self.messageList[(self.messageList.count - 1)].sending = false
                        self.messageList[(self.messageList.count - 1)].sendSuccess = false
                        self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                            self.packChatData()
                            PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: 发送图片内容
    func userSendImage(imageObject:UIImage,saveModel:PTChatModel,resend:Bool? = false) {
        self.setTypingIndicatorViewHidden(false)
        var imageSizeType:PTOpenAIImageSize
        switch AppDelegate.appDelegate()!.appConfig.aiDrawSize.width {
        case 1024:
            imageSizeType = .size1024
        case 512:
            imageSizeType = .size512
        case 256:
            imageSizeType = .size256
        default:
            imageSizeType = .size256
        }
        
        self.apiShare.imageVariation(image: imageObject,numberofImages: AppDelegate.appDelegate()!.appConfig.getImageCount, imageSize: imageSizeType) { model, error in
            if error == nil {
                self.messageList[(self.messageList.count - 1)].sending = false
                self.messageList[(self.messageList.count - 1)].sendSuccess = true
                self.receivedImage(urlArr: model!.data!, saveModel: saveModel, sendIndex: (self.messageList.count - 1),resend: resend)
            } else {
                PTNSLogConsole(error!.localizedDescription)
                PTGCDManager.gcdMain {
                    self.setTypingIndicatorViewHidden(true)
                    saveModel.messageSendSuccess = false
                    if resend! {
                        self.chatModels[(self.chatModels.count - 1)] = saveModel
                    } else {
                        self.chatModels.append(saveModel)
                    }
                    self.historyModel?.historyModel = self.chatModels
                    self.refreshViewAndLoadNewData {
                        self.messageList[(self.messageList.count - 1)].sending = false
                        self.messageList[(self.messageList.count - 1)].sendSuccess = false
                        self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                            self.packChatData()
                            PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: 發送文字內容
    func sendTextFunction(str:String,saveModel:PTChatModel,sectionIndex:Int,resend:Bool? = false,flagType:ChatIsFlag) {
        self.setTypingIndicatorViewHidden(false)
        switch self.chatCase {
        case .chat(type:.edit):
            self.chatCase = .chat(type: .normal)
            self.editString = ""
            PTGCDManager.gcdMain {
                self.messageInputBar.setStackViewItems([], forStack: .top, animated: true)
            }
                        
            self.apiShare.sendEdits(input: self.editString, instruction: str) { model, error in
                PTNSLogConsole("Edit API result>>:\(String(describing: model))")
                PTGCDManager.gcdBackground {
                    PTGCDManager.gcdMain {
                        self.setTypingIndicatorViewHidden(true)
                    }
                }
                if error != nil {
                    PTGCDManager.gcdMain {
                        saveModel.messageSendSuccess = false
                        if resend! {
                            self.chatModels[sectionIndex] = saveModel
                        } else {
                            self.chatModels.append(saveModel)
                        }
                        self.historyModel?.historyModel = self.chatModels
                        self.refreshViewAndLoadNewData {
                            self.messageList[sectionIndex].sending = false
                            self.messageList[sectionIndex].sendSuccess = false
                            self.reloadSomeSection(itemIndex: sectionIndex) {
                                self.packChatData()
                                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                            }
                        }
                    }
                } else {
                    saveModel.messageSendSuccess = true
                    self.messageList[sectionIndex].sending = false
                    self.messageList[sectionIndex].sendSuccess = true
                    PTGCDManager.gcdMain {
                        AppDelegate.appDelegate()!.appConfig.totalToken += Double(model?.usage?.total_tokens ?? 0)
                        AppDelegate.appDelegate()!.appConfig.totalTokenCost += AppDelegate.appDelegate()!.appConfig.tokenCostCalculation(type: .gpt3(.davinci), usageModel: model!.usage!)
                        
                        let costModel = PTCostMainModel()
                        costModel.historyType = 0
                        costModel.question = str
                        costModel.answer = model?.choices?.first?.text ?? ""
                        costModel.tokenUsage = model!.usage!
                        costModel.costDate = Date().dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                        costModel.modelName = OpenAIModelType.gpt3(.davinci).modelName
                        self.costHistoriaSave(model: costModel)
                        
                        self.setTokenButton()
                        self.reloadSomeSection(itemIndex: sectionIndex) {
                            self.saveQAndAText(question: model?.choices?.first?.text ?? "", saveModel: saveModel,sendIndex: sectionIndex)
                        }
                    }
                }
            }
        case .chat(type: .normal):
            if self.historyModel!.systemContent.stringIsEmpty() {
                let type = AppDelegate.appDelegate()!.appConfig.getAIMpdelType(typeString: AppDelegate.appDelegate()!.appConfig.aiModelType)
                switch type {
                case .chat(.chatgpt),.chat(.chatgpt0301),.chat(.chatgpt4),.chat(.chatgpt40314),.chat(.chatgpt432k),.chat(.chatgpt432k0314):
                    self.gpt3xSendMessage(str: str, saveModel: saveModel, sectionIndex: sectionIndex, resend: resend!, type: type)
                default:
                    self.apiShare.sendCompletions(prompt: str,modelType: type,temperature: AppDelegate.appDelegate()!.appConfig.aiSmart,maxTokens: 2048) { model, error in
                        PTGCDManager.gcdBackground {
                            PTGCDManager.gcdMain {
                                self.setTypingIndicatorViewHidden(true)
                            }
                        }
                        if error != nil {
                            PTGCDManager.gcdMain {
                                saveModel.messageSendSuccess = false
                                if resend! {
                                    self.chatModels[sectionIndex] = saveModel
                                } else {
                                    self.chatModels.append(saveModel)
                                }
                                self.historyModel?.historyModel = self.chatModels
                                self.refreshViewAndLoadNewData {
                                    self.messageList[sectionIndex].sending = false
                                    self.messageList[sectionIndex].sendSuccess = false
                                    self.reloadSomeSection(itemIndex: sectionIndex) {
                                        self.packChatData()
                                        PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                    }
                                }
                            }
                        } else {
                            PTGCDManager.gcdMain {
                                AppDelegate.appDelegate()!.appConfig.totalToken += Double(model?.usage?.total_tokens ?? 0)
                                AppDelegate.appDelegate()!.appConfig.totalTokenCost += AppDelegate.appDelegate()!.appConfig.tokenCostCalculation(type: type, usageModel: model!.usage!)
                                self.setTokenButton()
                                
                                let costModel = PTCostMainModel()
                                costModel.historyType = 0
                                costModel.question = str
                                costModel.answer = model?.choices?.first?.text ?? ""
                                costModel.tokenUsage = model!.usage!
                                costModel.costDate = Date().dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                costModel.modelName = type.modelName
                                self.costHistoriaSave(model: costModel)

                                saveModel.messageSendSuccess = true
                                self.messageList[sectionIndex].sending = false
                                self.messageList[sectionIndex].sendSuccess = true
                                self.reloadSomeSection(itemIndex: sectionIndex) {
                                    self.saveQAndAText(question: model?.choices?.first?.text ?? "", saveModel: saveModel,sendIndex: sectionIndex)
                                }
                            }
                        }
                    }
                }
            } else {
                var type = AppDelegate.appDelegate()!.appConfig.getAIMpdelType(typeString: AppDelegate.appDelegate()!.appConfig.aiModelType)
                switch type {
                case .chat(.chatgpt),.chat(.chatgpt0301),.chat(.chatgpt4),.chat(.chatgpt40314),.chat(.chatgpt432k),.chat(.chatgpt432k0314): break
                default:
                    type = OpenAIModelType.chat(.chatgpt)
                }
                
                self.gpt3xSendMessage(str: str, saveModel: saveModel, sectionIndex: sectionIndex, resend: resend!, type: type)
            }
        case .draw(type: .normal):
            PTNSLogConsole("我要畫畫")
            self.drawImage(str: str,saveModel: saveModel,indexSection: sectionIndex,resend: resend)
        case .draw(type: .edit):
            PTNSLogConsole("我要PS")
            let date = Date()
            
            self.attMessageSend(date: date, saveModel: saveModel, str: str,isFlagged: flagType, error: nil, sendToServices: true)
        }
    }
    
    func gpt3xSendMessage(str:String,saveModel:PTChatModel,sectionIndex:Int,resend:Bool,type:OpenAIModelType) {
        
        var chat: [PTSendChatMessageModel]
        if self.historyModel!.systemContent.stringIsEmpty() {
            chat = [PTSendChatMessageModel(role: PTSendRole.user.rawValue, content: str)]
        } else {
            chat = [PTSendChatMessageModel(role: PTSendRole.system.rawValue, content: self.historyModel!.systemContent),PTSendChatMessageModel(role: PTSendRole.user.rawValue, content: str)]
        }
        
        let sendChatModel = PTSendChatModel()
        sendChatModel.messages = chat
        sendChatModel.model = type.modelName
        sendChatModel.temperature = (AppDelegate.appDelegate()!.appConfig.aiSmart * 2)
        sendChatModel.max_tokens = 4096
        
        self.apiShare.sendChat(sendModel: sendChatModel) { model, error in
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    self.setTypingIndicatorViewHidden(true)
                }
            }
            if error != nil {
                PTGCDManager.gcdBackground {
                    PTGCDManager.gcdMain {
                        saveModel.messageSendSuccess = false
                        if resend {
                            self.chatModels[sectionIndex] = saveModel
                        } else {
                            self.chatModels.append(saveModel)
                        }
                        self.historyModel?.historyModel = self.chatModels
                        self.refreshViewAndLoadNewData {
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    self.messageList[sectionIndex].sending = false
                                    self.messageList[sectionIndex].sendSuccess = false
                                    self.reloadSomeSection(itemIndex: sectionIndex) {
                                        self.packChatData()
                                        PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                PTGCDManager.gcdBackground {
                    PTGCDManager.gcdMain {
                        AppDelegate.appDelegate()!.appConfig.totalToken += Double(model?.usage?.total_tokens ?? 0)
                        AppDelegate.appDelegate()!.appConfig.totalTokenCost += AppDelegate.appDelegate()!.appConfig.tokenCostCalculation(type: type, usageModel: model!.usage!)
                        self.setTokenButton()
                        
                        let costModel = PTCostMainModel()
                        costModel.historyType = 0
                        costModel.question = str
                        costModel.answer = model?.choices?.first?.message?.content ?? ""
                        costModel.tokenUsage = model!.usage!
                        costModel.costDate = Date().dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                        costModel.modelName = type.modelName
                        self.costHistoriaSave(model: costModel)

                        saveModel.messageSendSuccess = true
                        self.messageList[sectionIndex].sending = false
                        self.messageList[sectionIndex].sendSuccess = true
                        self.reloadSomeSection(itemIndex: sectionIndex) {
                            self.saveQAndAText(question: model?.choices?.first?.message?.content ?? "", saveModel: saveModel,sendIndex: sectionIndex)
                        }
                    }
                }
            }
        }
    }
            
    func saveQAndAText(question:String,saveModel:PTChatModel,sendIndex:Int) {
        let botDate = Date()
        
        saveModel.messageDateString = botDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        self.chatModels.append(saveModel)

        let botMessageModel = PTChatModel()
        botMessageModel.messageDateString = botDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        botMessageModel.messageType = 0
        botMessageModel.messageText = question
        botMessageModel.outgoing = false
        self.chatModels.append(botMessageModel)
        
        var botMessage = PTMessageModel(text: question, user: PTChatData.share.bot, messageId: UUID().uuidString, date: botDate)
        botMessage.sending = false
    
        self.historyModel?.historyModel = self.chatModels
        self.packChatData()
        self.messagesCollectionView.reloadData {
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    self.insertMessage(botMessage)
                }
            }
        }
    }
    
    func receivedImage(urlArr:[PTImageGenerationData],saveModel:PTChatModel,sendIndex:Int,resend:Bool? = false) {
        PTGCDManager.gcdBackground {
            PTGCDManager.gcdMain {
                self.setTypingIndicatorViewHidden(true)
            }
        }
        saveModel.messageSendSuccess = true
        PTGCDManager.gcdBackground {
            PTGCDManager.gcdMain {
                if !resend! {
                    self.chatModels.append(saveModel)
                }
                self.reloadSomeSection(itemIndex: sendIndex) {

                    PTGCDManager.gcdGroup(label: "AppendImageMessage", threadCount: urlArr.count) { dispatchSemaphore, dispatchGroup, currentIndex in
                        PTGCDManager.gcdBackground {
                            let imageURL = urlArr[currentIndex].url
                            let date = Date()

                            let botMessage = PTChatModel()
                            botMessage.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                            botMessage.messageType = 2
                            botMessage.messageMediaURL = imageURL
                            botMessage.outgoing = false
                            self.chatModels.append(botMessage)
                            let message = PTMessageModel(imageURL: URL(string: imageURL)!, user: PTChatData.share.bot, messageId: UUID().uuidString, date: date,sendSuccess: true)
                            PTGCDManager.gcdMain {
                                self.insertMessage(message) {
                                    dispatchSemaphore.signal()
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    } jobDoneBlock: {
                        saveModel.messageSendSuccess = true
                        if resend! {
                            self.chatModels[sendIndex] = saveModel
                        } else {
                            self.chatModels.append(saveModel)
                        }
                        self.historyModel?.historyModel = self.chatModels
                        self.reloadSomeSection(itemIndex: sendIndex)
                        self.packChatData()
                        AppDelegate.appDelegate()!.appConfig.totalTokenCost += AppDelegate.appDelegate()!.appConfig.tokenCostImageCalculation(imageCount: urlArr.count)
                        self.setTokenButton()
                        
                        var imageSizeType:String = ""
                        switch AppDelegate.appDelegate()!.appConfig.aiDrawSize.width {
                        case 1024:
                            imageSizeType = PTOpenAIImageSize.size1024.rawValue
                        case 512:
                            imageSizeType = PTOpenAIImageSize.size512.rawValue
                        case 256:
                            imageSizeType = PTOpenAIImageSize.size256.rawValue
                        default:
                            imageSizeType = PTOpenAIImageSize.size256.rawValue
                        }

                        let costModel = PTCostMainModel()
                        costModel.question = saveModel.messageText
                        costModel.historyType = 1
                        costModel.costDate = Date().dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                        costModel.imageURL = urlArr
                        costModel.imageSize = imageSizeType
                        self.costHistoriaSave(model: costModel)
                    }
                }
            }
        }
    }
        
    //MARK: 消费记录
    func costHistoriaSave(model:PTCostMainModel) {
        var hostoria = AppDelegate.appDelegate()!.appConfig.getCostHistoriaData()
        hostoria.append(model)
        AppDelegate.appDelegate()!.appConfig.costHistory = hostoria.kj.JSONObjectArray()
    }
}

//MARK: OSSSpeechDelegate
extension PTChatViewController:OSSSpeechDelegate {
    func voiceFilePathTranscription(withText text: String) {
        
    }
    
    func deleteVoiceFile(withFinish finish: Bool, withError error: Error?) {
        print("\(finish)  error:\(String(describing: error?.localizedDescription))")
    }
    
    func didFinishListening(withText text: String) {
        PTNSLogConsole("didFinishListening>>>>>>>>>>>>>\(text)")
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        
    }
    
    func didFailToCommenceSpeechRecording() {
        
    }
    
    func didCompleteTranslation(withText text: String) {
        PTNSLogConsole("Listening>>>>>>>>>>>>>\(text)")
        if self.translateToText {
            self.maskView.translateLabel.text = text
            self.maskView.translateLabel.isHidden = false
            var textHeight = self.maskView.translateLabel.sizeFor(size: CGSize(width: CGFloat.kSCREEN_WIDTH - 40, height: CGFloat(MAXFLOAT))).height + 10
            
            let centerY = CGFloat.kSCREEN_HEIGHT / 2
            let textMaxHeight = (centerY - CGFloat.statusBarHeight() - 44 - 5)
            if textHeight >= textMaxHeight {
                textHeight = textMaxHeight
            }
            
            self.maskView.translateLabel.snp.updateConstraints { make in
                make.height.equalTo(textHeight)
            }
        } else {
            self.maskView.translateLabel.isHidden = true
            self.maskView.translateLabel.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        
    }
    
    func didFinishListening(withAudioFileURL url: URL, withText text: String) {
        PTNSLogConsole("url:\(url) \ntext:\(text)")
        let date = Date()
        let voiceURL = URL(fileURLWithPath: url.absoluteString.replacingOccurrences(of: "file://", with: ""))
        var voiceMessage = PTMessageModel(audioURL: voiceURL, user: PTChatData.share.user, messageId: UUID().uuidString, date: date,sendSuccess: false)
        voiceMessage.sending = true
        let saveModel = PTChatModel()
        if self.sendTranslateText {
            saveModel.messageType = 0
        } else {
            saveModel.messageType = 1
            saveModel.messageMediaURL = voiceURL.lastPathComponent
        }
        saveModel.messageText = text
        saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        saveModel.outgoing = true
        if self.isSendVoice {
            self.isSendVoice = false
            if self.sendTranslateText {
                self.insertMessages([text])
                self.maskView.translateLabel.text = ""
            } else {
                self.insertMessage(voiceMessage) {
                    self.sendTextFunction(str: text, saveModel: saveModel, sectionIndex: self.messageList.count - 1,flagType: .PASS)
                }
            }
            self.messagesCollectionView.scrollToLastItem(animated: true)
            self.sendTranslateText = false
        } else {
            self.speechKit.deleteVoiceFolderItem(url: URL(fileURLWithPath: url.absoluteString.replacingOccurrences(of: "file://", with: "")))
        }
    }
}

//MARK: LXFEmptyDataSetable
extension PTChatViewController:LXFEmptyDataSetable {
    func showEmptyDataSet(currentScroller: UIScrollView) {
        self.lxf_EmptyDataSet(currentScroller) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            let color:UIColor = .gobalTextColor
            return [
                .tipStr : PTLanguage.share.text(forKey: "chat_Empty"),
                .tipColor : color,
                .verticalOffset : 0,
                .tipImage : UIImage(systemName:"info.circle.fill")!.withTintColor(.gobalTextColor, renderingMode: .automatic)
            ]
        }
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        return NSAttributedString()
    }
}

extension PTChatViewController {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension PTChatViewController:UITextFieldDelegate {}

//MARK: 第一次使用APP的时候的用户使用提示
extension PTChatViewController: CoachMarksControllerDataSource {
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
        if Gobal_device_info.isPad {
            switch index {
            case 0:
                return coachMarksController.helper.makeCoachMark(for: self.rightInputStackButton)
            case 1:
                return coachMarksController.helper.makeCoachMark(for: self.imageBarButton)
            case 2:
                return coachMarksController.helper.makeCoachMark(for: self.textImageBarButton)
            case 3:
                return coachMarksController.helper.makeCoachMark(for: self.inputBarChatSentence)
            case 4:
                return coachMarksController.helper.makeCoachMark(for: self.tfImageButton)
            case 5:
                return coachMarksController.helper.makeCoachMark(for: self.tagSuggestionButton)
            default:
                return coachMarksController.helper.makeCoachMark()
            }
        } else {
            switch index {
            case 0:
                return coachMarksController.helper.makeCoachMark(for: self.titleButton)
            case 1:
                return coachMarksController.helper.makeCoachMark(for: self.optionButton)
            case 2:
                return coachMarksController.helper.makeCoachMark(for: self.settingButton)
            case 3:
                return coachMarksController.helper.makeCoachMark(for: self.rightInputStackButton)
            case 4:
                return coachMarksController.helper.makeCoachMark(for: self.imageBarButton)
            case 5:
                return coachMarksController.helper.makeCoachMark(for: self.textImageBarButton)
            case 6:
                return coachMarksController.helper.makeCoachMark(for: self.inputBarChatSentence)
            case 7:
                return coachMarksController.helper.makeCoachMark(for: self.tfImageButton)
            case 8:
                return coachMarksController.helper.makeCoachMark(for: self.tagSuggestionButton)
            default:
                return coachMarksController.helper.makeCoachMark()
            }
        }
    }
}

extension PTChatViewController: CoachMarksControllerAnimationDelegate {
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

extension PTChatViewController : CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        AppDelegate.appDelegate()?.appConfig.firstCoach = false
        if index == (self.coachArray.count - 1) {
            self.whatNews()
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        
    }
}

extension PTChatViewController {
    func checkSentence(checkWork:String,completed:@escaping ((_ useCheckApi:Bool,_ isFlagged:Bool,_ error:AFError?)->Void)) {
        PTGCDManager.gcdMain {
            let throwThisApi:Bool = AppDelegate.appDelegate()!.appConfig.checkSentence
            if throwThisApi {
                self.apiShare.checkSentence(word: checkWork) { model, error in
                    if model != nil {
                        completed(throwThisApi,model!.results?.first?.flagged ?? false,nil)
                    } else {
                        completed(throwThisApi,false,error)
                    }
                }
            } else {
                completed(throwThisApi,false,nil)
            }
        }
    }
}

// MARK: - CartoonGanModelDelegate
extension PTChatViewController: ModelDelegate {
    func model(_ model: Any, didFinishProcessing image: UIImage) {
        PTGCDManager.gcdMain {
            self.chatModels[self.chatModels.count - 1].messageSendSuccess = true
            self.messageList[(self.messageList.count - 1)].sending = true
            self.messageList[(self.messageList.count - 1)].sendSuccess = false
            self.historyModel?.historyModel = self.chatModels
            self.reloadSomeSection(itemIndex: (self.messageList.count - 1)) {
                let date = Date()
                let dateString = date.dateFormat(formatString: "yyyy-MM-dd-HH-mm-ss")
                let fileName = "bot_cartoon_\(dateString).png"
                PTGCDManager.gcdMain {
                    AppDelegate.appDelegate()!.appConfig.saveUserSendImage(image: image, fileName: fileName) { finish in
                        if finish {
                            PTGCDManager.gcdMain {
                                self.setTypingIndicatorViewHidden(true)
                            }
                            
                            let saveModel = PTChatModel()
                            saveModel.messageType = 2
                            saveModel.messageDateString = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                            saveModel.messageSendSuccess = true
                            saveModel.localFileName = fileName
                            saveModel.outgoing = false
                            self.chatModels.append(saveModel)
                            let message = PTMessageModel(image: image, user: PTChatData.share.bot, messageId: UUID().uuidString, date: date, sendSuccess: true,fileName: fileName)
                            self.historyModel?.historyModel = self.chatModels
                            PTGCDManager.gcdMain {
                                self.insertMessage(message) {
                                    self.refreshViewAndLoadNewData()
                                    self.packChatData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func model(_ model: Any, didFailedProcessing error: ModelError) {
        PTGCDManager.gcdMain {
            self.setTypingIndicatorViewHidden(true)
            self.chatModels[self.chatModels.count - 1].messageSendSuccess = false
            self.historyModel?.historyModel = self.chatModels
            self.messageList[self.messageList.count - 1].sending = false
            self.messageList[self.messageList.count - 1].sendSuccess = false
            self.reloadSomeSection(itemIndex: self.messageList.count - 1)
            PTBaseViewController.gobal_drop(title: error.localizedDescription)
        }
    }

    func model(_ model: Any, didFinishAllocation error: ModelError?) {
        PTGCDManager.gcdMain {
            self.setTypingIndicatorViewHidden(true)
            if error != nil {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
            }
        }
    }
}

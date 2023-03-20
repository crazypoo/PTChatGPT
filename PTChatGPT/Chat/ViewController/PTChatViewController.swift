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
import SDWebImage
import AVFAudio
import LXFProtocolTool
import SwifterSwift

fileprivate extension String{
    static let saveNavTitle = PTLanguage.share.text(forKey: "about_SavedChat")
    
    static let copyString = PTLanguage.share.text(forKey: "chat_Copy")
    static let editString = PTLanguage.share.text(forKey: "chat_Edit_question")
    static let playString = PTLanguage.share.text(forKey: "chat_Speak_text")
    static let saveString = PTLanguage.share.text(forKey: "chat_Favourite")
    static let thinking = PTLanguage.share.text(forKey: "chat_Thinking")
    static let resend = PTLanguage.share.text(forKey: "chat_Resend")
}

enum PTChatCase
{
    case draw
    case chat
}

class PTChatViewController: MessagesViewController {
            
    lazy var titleButton:BKLayoutButton = {
        let view = BKLayoutButton()
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.font = .appfont(size: 24,bold: true)
        view.setTitleColor(.gobalTextColor, for: .normal)
        view.layoutStyle = .leftTitleRightImage
        view.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
        view.setMidSpacing(5)
        view.addActionHandlers { sender in            
            let popover = PTPopoverControl(currentSelect: self.historyModel!)
            popover.view.backgroundColor = .gobalBackgroundColor.withAlphaComponent(0.45)
            self.popover(popoverVC: popover, popoverSize: CGSize(width: popover.popoverWidth, height: CGFloat(self.segDataArr.count) * popover.popoverCellBaseHeight), sender: sender, arrowDirections: .up)
            popover.selectedBlock = { model in
                self.historyModel = model
                self.setTitleViewFrame(withModel: self.historyModel!)
                self.segDataArr = AppDelegate.appDelegate()!.appConfig.tagDataArr
            }
            popover.refreshTagArr = {
                self.segDataArr = AppDelegate.appDelegate()!.appConfig.tagDataArr
            }
        }
        return view
    }()
        
    var segDataArr:[PTSegHistoryModel] = {
        var arr = [PTSegHistoryModel]()
        let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory
        let dataArr = dataString!.components(separatedBy: kSeparatorSeg)
        dataArr.enumerated().forEach { index,value in
            let model = PTSegHistoryModel.deserialize(from: value)
            arr.append(model!)
        }
        return arr
    }()

    lazy var maskView:PTVoiceActionView = {
        let view = PTVoiceActionView()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        return view
    }()
        
    var sendTranslateText:Bool = false
    var translateToText:Bool = false
    var soundRecorder = PTSoundRecorder()
    
    var chatCase:PTChatCase = .chat
    
    lazy var audioPlayer = PTAudioPlayer(messageCollectionView: messagesCollectionView)

    var editMessage:Bool = false
    var editString:String = ""
    var openAI:OpenAISwift = OpenAISwift(authToken: AppDelegate.appDelegate()!.appConfig.apiToken)
    lazy var messageList:[PTMessageModel] = []
    let speechKit = OSSSpeech.shared
        
    private(set) lazy var refreshControl:UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessage), for: .valueChanged)
        return control
    }()
    
    lazy var closeEditButton:UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.automatic), for: .normal)
        view.addActionHandlers { sender in
            self.closeEditButton.isHidden = true
            self.closeEditButton.isUserInteractionEnabled = false
            self.voiceTypeButton.isHidden = false
            self.voiceTypeButton.isUserInteractionEnabled = true
            self.editMessage = false
            self.messageInputBar.inputTextView.resignFirstResponder()
            self.editString = ""
            self.messageInputBar.inputTextView.placeholder = "Aa"
        }
        return view
    }()
    
    lazy var sendTypeButton:UIButton = {
        let view = UIButton(type: .custom)
        view.isSelected = false
        view.setImage(UIImage(systemName: "character.bubble.fill")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setImage(UIImage(systemName: "paintbrush.fill")?.withTintColor(.black, renderingMode: .automatic), for: .selected)
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            if sender.isSelected
            {
                self.chatCase = .draw
            }
            else
            {
                self.chatCase = .chat
            }
        }
        return view
    }()
    
    lazy var tapVoiceSaveString = ""
    var isRecording:Bool = false
    var isSendVoice:Bool = false
    
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
    lazy var voiceTypeButton:UIButton = {
        let view = UIButton(type: .custom)
        view.isSelected = false
        view.setImage(UIImage(systemName: "mic")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
        view.setImage(UIImage(systemName: "mic.fill")?.withTintColor(.black, renderingMode: .automatic), for: .selected)
        view.addActionHandlers { sender in
            self.messageInputBar.inputTextView.resignFirstResponder()
            if self.voiceCanTap
            {
                sender.isSelected = !sender.isSelected
                if sender.isSelected
                {
                    if !self.messageInputBar.inputTextView.text.stringIsEmpty()
                    {
                        self.tapVoiceSaveString = self.messageInputBar.inputTextView.text
                        self.messageInputBar.inputTextView.text = ""
                    }
                    self.messageInputBar.addSubview(self.voiceButton)
                    self.voiceButton.snp.makeConstraints { make in
                        make.left.right.equalTo(self.messageInputBar.inputTextView)
                        make.height.bottom.equalTo(self.voiceTypeButton)
                    }
                }
                else
                {
                    if !self.tapVoiceSaveString.stringIsEmpty()
                    {
                        self.messageInputBar.inputTextView.text = self.tapVoiceSaveString
                    }
                    self.tapVoiceSaveString = ""
                    self.voiceButton.removeFromSuperview()
                }
            }
            else
            {
                PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Can_not_send_voice"))
            }
        }
        return view
    }()

    var onlyShowSave:Bool = false
    
    var historyModel:PTSegHistoryModel? {
        didSet {
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
    
    init(saveModel:PTChatModel)
    {
        super.init(nibName: nil, bundle: nil)
        self.onlyShowSave = true
        
        let models = saveModel
        
        let questionModel:PTMessageModel
        switch models.questionType {
        case 0:
            print(String(describing: models.questionDate))
            questionModel = PTMessageModel(text: models.question, user: PTChatData.share.user, messageId: UUID().uuidString, date: models.questionDate.toDate()!.date)
        default:
            let voiceURL = self.speechKit.getDocumentsDirectory().appendingPathComponent(models.questionVoiceURL)
            questionModel = PTMessageModel(audioURL: voiceURL, user: PTChatData.share.user, messageId: UUID().uuidString, date: models.questionDate.toDate()!.date)
        }
        self.messageList.append(questionModel)
        let answerModel:PTMessageModel
        switch models.answerType {
        case 0:
            answerModel = PTMessageModel(text: models.answer, user: PTChatData.share.bot, messageId: UUID().uuidString, date: models.answerDate.toDate()!.date)
        default:
            answerModel = PTMessageModel(imageURL: URL(string: models.answerImageURL)!, user: PTChatData.share.bot, messageId: UUID().uuidString, date: models.answerDate.toDate()!.date)
        }
        self.messageList.append(answerModel)
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
        HSNavControl.GobalNavControl(nav: self.navigationController!,textColor: .gobalTextColor,navColor: .gobalBackgroundColor)
        messagesCollectionView.contentInsetAdjustmentBehavior = .automatic
        
        StatusBarManager.shared.style = PTDrakModeOption.isLight ? .lightContent : .darkContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.maskView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.messagesCollectionView.reloadData()
        AppDelegate.appDelegate()?.window?.addSubview(self.maskView)
        self.maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        if !AppDelegate.appDelegate()!.appConfig.apiToken.stringIsEmpty()
        {
            NotificationCenter.default.addObserver(self, selector: #selector(self.showURLNotifi(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdDetailDisplayNotification), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.adHide(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdSkipNotification), object: nil)
        }
        
        self.configureMessageCollectionView()
        if self.onlyShowSave
        {
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
        }
        else
        {
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshView), name: NSNotification.Name(rawValue: kRefreshController), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshViewAndLoadNewData), name: NSNotification.Name(rawValue: kRefreshControllerAndLoadNewData), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCurrentTagData), name: NSNotification.Name(rawValue: kRefreshCurrentTagData), object: nil)

            let logout = UIButton(type: .custom)
            logout.imageView?.contentMode = .scaleAspectFit
            logout.setImage(UIImage(systemName: "gear")?.withTintColor(.black, renderingMode: .automatic), for: .normal)
            logout.addActionHandlers { sender in
                let vc = PTSettingListViewController(user: PTChatUser(senderId: "0", displayName: "0"))
                self.navigationController?.pushViewController(vc)
            }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logout)
            
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
                        PTGCDManager.gcdAfter(time: 0.35) {
                            let textKey = PTLanguage.share.text(forKey: "alert_Tag_set")
                            let aiKey = PTLanguage.share.text(forKey: "alert_AI_Set")
                            UIAlertController.base_textfiele_alertVC(title:textKey,titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey,aiKey], textFieldTexts: ["",""], keyboardType: [.default,.default],textFieldDelegate: self) { result in
                                let newKey:String? = result[textKey]!
                                let newAiKey:String? = result[aiKey]
                                if !(newKey ?? "").stringIsEmpty()
                                {
                                    if self.segDataArr.contains(where: {$0.keyName == newKey}) {
                                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_error"))
                                    } else {
                                        let newTag = PTSegHistoryModel()
                                        newTag.keyName = newKey!
                                        newTag.systemContent = newAiKey ?? ""
                                        newTag.historyJson = ""
                                        self.segDataArr.append(newTag)
                                        var jsonArr = [String]()
                                        self.segDataArr.enumerated().forEach { index,value in
                                            jsonArr.append(value.toJSON()!.toJSON()!)
                                        }
                                        AppDelegate.appDelegate()?.appConfig.segChatHistory = jsonArr.joined(separator: kSeparatorSeg)
                                        self.historyModel = newTag
                                        self.setTitleViewFrame(withModel: self.historyModel!)
                                    }
                                } else {
                                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                                }
                            }
                        }
                    case .deleteHistory:
                        PTGCDManager.gcdAfter(time: 0.35) {
                            UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_Ask_clean_current_chat_record"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                                
                            } moreBtn: { index, title in
                                                                
                                var arr = [PTSegHistoryModel]()
                                if let dataArr = AppDelegate.appDelegate()?.appConfig.segChatHistory.components(separatedBy: kSeparatorSeg) {
                                    self.historyModel?.historyJson = ""

                                    dataArr.enumerated().forEach { index,value in
                                        let model = PTSegHistoryModel.deserialize(from: value)
                                        arr.append(model!)
                                    }
                                    for (index,value) in arr.enumerated() {
                                        if value.keyName == self.historyModel?.keyName {
                                            arr[index] = self.historyModel!
                                            break
                                        }
                                    }
                                    var newJsonArr = [String]()
                                    arr.enumerated().forEach { index,value in
                                        newJsonArr.append(value.toJSON()!.toJSON()!)
                                    }
                                    AppDelegate.appDelegate()!.appConfig.segChatHistory = newJsonArr.joined(separator: kSeparatorSeg)
                                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
                                    self.refreshCurrentTagData()
                                } else {
                                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_error"))
                                }
                            }
                        }
                    default:break
                    }
                }
            }
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addChat)
            
            self.navigationItem.titleView = self.titleButton
            
            speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum(rawValue: AppDelegate.appDelegate()!.appConfig.language)!)
            speechKit.utterance?.rate = 0.45

            var arr = [PTSegHistoryModel]()
            if let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory {
                let dataArr = dataString.components(separatedBy: kSeparatorSeg)
                dataArr.enumerated().forEach { index,value in
                    let model = PTSegHistoryModel.deserialize(from: value)
                    arr.append(model!)
                }
                self.historyModel = arr.first!
                self.setTitleViewFrame(withModel: self.historyModel!)
            }
            
            self.soundRecorder.onUpdate = { soundSamples in
                PTGCDManager.gcdMain {
                    self.maskView.visualizerView.updateSamples(soundSamples)
                }
            }
            self.configureMessageInputBar()
            self.speechKit.delegate = self
        }
        
        self.speechKit.srp.requestAuthorization { authStatus in
            let status = OSSSpeechKitAuthorizationStatus(rawValue: authStatus.rawValue) ?? .notDetermined
            switch status
            {
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
    }
        
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }

    @objc func refreshView()
    {
        self.messagesCollectionView.reloadData()
    }
        
    @objc func refreshCurrentTagData()
    {
        var arr = [PTSegHistoryModel]()
        if let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory {
            let dataArr = dataString.components(separatedBy: kSeparatorSeg)
            dataArr.enumerated().forEach { index,value in
                let model = PTSegHistoryModel.deserialize(from: value)
                arr.append(model!)
            }
            
            for (value) in arr {
                if value.keyName == self.historyModel!.keyName
                {
                    self.historyModel = value
                    break
                }
            }
        }
    }
    
    @objc func refreshViewAndLoadNewData()
    {
        self.messageList.removeAll()
        let userHistoryModelString = self.historyModel!.historyJson
        if !userHistoryModelString.stringIsEmpty() {
            let userModelsStringArr = userHistoryModelString.components(separatedBy: kSeparator)
            userModelsStringArr.enumerated().forEach { index,value in
                let models = PTChatModel.deserialize(from: value)
                
                let questionModel:PTMessageModel
                switch models!.questionType {
                case 0:
                    print(String(describing: models!.questionDate))
                    questionModel = PTMessageModel(text: models!.question, user: PTChatData.share.user, messageId: UUID().uuidString, date: models!.questionDate.toDate()!.date)
                default:
                    let voiceURL = self.speechKit.getDocumentsDirectory().appendingPathComponent(models!.questionVoiceURL)
                    questionModel = PTMessageModel(audioURL: voiceURL, user: PTChatData.share.user, messageId: UUID().uuidString, date: models!.questionDate.toDate()!.date)
                }
                self.messageList.append(questionModel)
                let answerModel:PTMessageModel
                switch models!.answerType {
                case 0:
                    answerModel = PTMessageModel(text: models!.answer, user: PTChatData.share.bot, messageId: UUID().uuidString, date: models!.answerDate.toDate()!.date)
                default:
                    answerModel = PTMessageModel(imageURL: URL(string: models!.answerImageURL)!, user: PTChatData.share.bot, messageId: UUID().uuidString, date: models!.answerDate.toDate()!.date)
                }
                self.messageList.append(answerModel)
                self.messagesCollectionView.reloadData {
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        } else {
            self.messagesCollectionView.reloadData {
                self.messagesCollectionView.scrollToLastItem()
            }
        }
    }
    
    @objc func showURLNotifi(notifi:Notification)
    {
        let urlString = (notifi.object as! [String:String])["URLS"]
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func adHide(notifi:Notification)
    {
        PTNSLogConsole("广告隐藏")
        messageInputBar.alpha = 1
    }
    
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
            self.titleButton.isUserInteractionEnabled = true
            self.titleButton.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
            let att = NSMutableAttributedString.sj.makeText { make in
                make.append(model.keyName).font(.appfont(size: 17)).textColor(.gobalTextColor).alignment(.center).lineSpacing(5)
                make.append("\n\(model.systemContent)").font(.appfont(size: 14)).textColor(.lightGray).alignment(.center)
            }
            self.titleButton.setAttributedTitle(att, for: .normal)
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
            self.titleButton.isUserInteractionEnabled = true
            self.titleButton.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
        }
    }

    @objc func loadMoreMessage()
    {
        DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + 1) {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.register(PTChatCustomCell.self)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = .gobalBackgroundColor
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        showMessageTimestampOnSwipeLeft = true // default false

        messagesCollectionView.refreshControl = refreshControl
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func configureMessageInputBar() {
        if AppDelegate.appDelegate()!.appConfig.firstUseApp
        {
            AppDelegate.appDelegate()!.appConfig.firstUseApp = false
            messageInputBar.alpha = 1
        }
        else
        {
            messageInputBar.alpha = 0
        }
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .gobalBackgroundColor
        messageInputBar.inputTextView.textColor = .gobalTextColor
        messageInputBar.inputTextView.tintColor = .gobalTextColor
        messageInputBar.sendButton.setTitle(PTLanguage.share.text(forKey: "chat_Send"), for: .normal)
        messageInputBar.sendButton.setTitleColor( .gobalTextColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            .gobalTextColor.withAlphaComponent(0.3),
            for: .highlighted)
        
        self.setInputBarFrame()
    }
        
    func setInputBarFrame()
    {
        let senderW = messageInputBar.sendButton.sizeFor(size: CGSize(width: CGFloat(MAXFLOAT), height: 44)).width + 10
        self.messageInputBar.sendButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.bottom.equalToSuperview().inset(CGFloat.kTabbarSaveAreaHeight + 10)
            make.width.equalTo(senderW)
        }
        
        self.messageInputBar.addSubviews([self.voiceTypeButton,self.sendTypeButton,self.closeEditButton])
        self.sendTypeButton.snp.makeConstraints { make in
            make.right.equalTo(messageInputBar.sendButton.snp.left).offset(-10)
            make.bottom.equalTo(messageInputBar.sendButton)
            make.width.height.equalTo(34)
        }
        
        self.voiceTypeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.bottom.size.equalTo(self.sendTypeButton)
        }
        
        self.messageInputBar.inputTextView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.voiceTypeButton.snp.right).offset(10)
            make.width.equalTo(CGFloat.kSCREEN_WIDTH - senderW - PTAppBaseConfig.share.defaultViewSpace * 2 - 10 * 2 - 34 * 2)
        }
        
        self.closeEditButton.snp.makeConstraints { make in
            make.edges.equalTo(self.voiceTypeButton)
        }
        self.closeEditButton.isHidden = true
        self.closeEditButton.isUserInteractionEnabled = false
    }
    
    // MARK: - Helpers
    func insertMessage(_ message: PTMessageModel) {
        messageList.append(message)
      // Reload last section to update header/footer labels and insert a new one
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
                
                if self?.messageList.count == 1
                {
                    self?.messagesCollectionView.reloadData()
                }
            })
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

    func sendVoiceMessage(text:String,saveModel:PTChatModel)
    {
        self.setTitleViewFrame(text: .thinking)
        switch self.chatCase {
        case .chat:
            self.openAI.sendEdits(with: text, input: self.editString) { result in
                switch result {
                case .success(let success):
                    let date = Date()
                    saveModel.answerDate = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                    saveModel.answerType = 0
                    saveModel.answer = success.choices.first?.text ?? ""

                    let botMessage = PTMessageModel(text: success.choices.first?.text ?? "", user: PTChatData.share.bot, messageId: UUID().uuidString, date: date)
                    self.insertMessage(botMessage)
                    PTGCDManager.gcdMain {
                        self.setTitleViewFrame(withModel: self.historyModel!)
                    }
                    self.chatModelToJsonString(model: saveModel)
                case .failure(let failure):
                    PTGCDManager.gcdMain {
                        self.setTitleViewFrame(withModel: self.historyModel!)
                        PTBaseViewController.gobal_drop(title: failure.localizedDescription)
                    }
                }
            }
        default:
            self.drawImage(str: text,saveModel: saveModel)
        }
    }

    //MARK: Voice action
    @objc func recordButtonPressed()
    {
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.maskView.visualizerView.start()
        self.soundRecorder.start()

        // 開始錄音
        self.isRecording = true
        PTNSLogConsole("開始錄音")
    }
    
    @objc func recordButtonReleased()
    {
        // 停止錄音
        self.isRecording = false
        PTNSLogConsole("停止錄音")
        self.soundRecorder.stop()
        self.maskView.visualizerView.stop()
        self.maskView.alpha = 0
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_end"), for: .normal)
        if self.isRecording
        {
            self.speechKit.recordVoice()
            self.isRecording = false
        }
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
                if touchPoint.x < centerX
                {
                    let newX = (touchPoint.x - centerX)
                    PTNSLogConsole(newX)
                    if abs(newX) >= (screenCenterX / 2)
                    {
                        self.maskView.visualizerView.backgroundColor = .red
                        self.maskView.visualizerView.snp.updateConstraints { make in
                            make.width.equalTo(150)
                            make.centerX.equalToSuperview().offset(-(screenCenterX / 2))
                        }
                        self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_cancel"), for: .normal)
                        self.maskView.actionInfoLabel.isHidden = false
                        self.maskView.actionInfoLabel.text = PTLanguage.share.text(forKey: "voice_Cancel_send")
                    }
                    else if abs(newX) <= 44
                    {
                        self.maskView.visualizerView.backgroundColor = self.maskView.visualizerViewBaseBackgroundColor
                        self.maskView.visualizerView.snp.updateConstraints { make in
                            make.centerX.equalToSuperview().offset(0)
                            make.width.equalTo(150)
                        }
                        self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_release"), for: .normal)
                        self.maskView.actionInfoLabel.isHidden = true
                    }
                    else
                    {
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
                }
                else if touchPoint.x > (screenCenterX + 44)
                {
                    self.translateToText = true
                    self.sendTranslateText = true
                    PTNSLogConsole("在右边")
                    self.maskView.visualizerView.snp.updateConstraints { make in
                        make.width.equalTo(CGFloat.kSCREEN_WIDTH - 40)
                    }
                    self.maskView.actionInfoLabel.isHidden = false
                    self.maskView.actionInfoLabel.text = PTLanguage.share.text(forKey: "voice_Change_to_text")
                }
                else
                {
                    self.translateToText = false
                    PTNSLogConsole("在中间")
                    self.maskView.visualizerView.snp.updateConstraints { make in
                        make.centerX.equalToSuperview().offset(0)
                        make.width.equalTo(150)
                    }
                    self.voiceButton.setTitle(PTLanguage.share.text(forKey: "button_Long_tap_release"), for: .normal)
                    self.maskView.actionInfoLabel.isHidden = true
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
                if touchPoint.x < centerX
                {
                    let newX = (touchPoint.x - centerX)
                    PTNSLogConsole(newX)
                    if abs(newX) >= (screenCenterX / 2)
                    {
                        self.isSendVoice = false
                    }
                    else if abs(newX) <= 44
                    {
                        self.isSendVoice = true
                    }
                    else
                    {
                        self.isSendVoice = false
                    }
                    PTNSLogConsole("在左边")
                }
                else if touchPoint.x > (screenCenterX + 44)
                {
                    self.isSendVoice = true
                }
                else
                {
                    self.isSendVoice = true
                }
            } else {
                self.isSendVoice = true
            }
            self.isRecording = false
            self.speechKit.endVoiceRecording()
            PTGCDManager.gcdMain {
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
    
    //MARK: 保存聊天記錄
    func chatModelToJsonString(model:PTChatModel) {
        self.saveHistory(jsonString: (model.toJSON()?.toJSON())!, key: uChatHistory)
    }
    
    func saveChatModelToJsonString(model:PTChatModel) {
        self.saveHistory(jsonString: (model.toJSON()?.toJSON())!, key: uSaveChat)
    }
    
    func saveHistory(jsonString:String,key:String)
    {
        PTGCDManager.gcdMain {
            var userHistoryModelString = ""
            switch key {
            case uChatHistory:
                var arr = [PTSegHistoryModel]()
                userHistoryModelString = AppDelegate.appDelegate()!.appConfig.segChatHistory
                let historyArr = userHistoryModelString.components(separatedBy: kSeparatorSeg)
                historyArr.enumerated().forEach { index,value in
                    let model = PTSegHistoryModel.deserialize(from: value)
                    arr.append(model!)
                }
                arr.enumerated().forEach { index,value in
                    if value.keyName == self.historyModel!.keyName {
                        arr[index].historyJson = jsonString
                    }
                }
                var newJsonArr = [String]()
                arr.enumerated().forEach { index,value in
                    newJsonArr.append(value.toJSON()!.toJSON()!)
                }
                AppDelegate.appDelegate()!.appConfig.segChatHistory = newJsonArr.joined(separator: kSeparatorSeg)
            case uSaveChat:
                userHistoryModelString = AppDelegate.appDelegate()!.appConfig.chatFavourtie
                if !userHistoryModelString.stringIsEmpty() {
                    var userModelsStringArr = userHistoryModelString.components(separatedBy: kSeparator)
                    userModelsStringArr.append(jsonString)
                    let saaveString = userModelsStringArr.joined(separator: kSeparator)
                    switch key {
                    case uChatHistory:
                        AppDelegate.appDelegate()!.appConfig.chatHistory = saaveString
                    case uSaveChat:
                        AppDelegate.appDelegate()!.appConfig.chatFavourtie = saaveString
                    default:
                        break
                    }
                    print(saaveString)
                } else {
                    AppDelegate.appDelegate()!.appConfig.chatFavourtie = jsonString
                    print(jsonString)
                }
            default:
                break
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            StatusBarManager.shared.style = UITraitCollection.current.userInterfaceStyle == .dark ? .lightContent : .darkContent
            setNeedsStatusBarAppearanceUpdate()
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
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
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
            imageView.sd_setImage(with: imageURL)
        } else {
//            imageView.kf.cancelDownloadTask()
        }
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
extension PTChatViewController:MessagesLayoutDelegate
{
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
        return 16
    }
}

//MARK: MessagesDataSource
extension PTChatViewController:MessagesDataSource
{
    func currentSender() -> MessageKit.SenderType {
        PTChatData.share.user
    }
    
    func numberOfSections(in _: MessagesCollectionView) -> Int {
      messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
      messageList[indexPath.section]
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

    func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
      NSAttributedString(
        string: PTLanguage.share.text(forKey: "chat_Read"),
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

    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
      let dateString = formatter.string(from: message.sentDate)
      return NSAttributedString(
        string: dateString,
        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),NSAttributedString.Key.foregroundColor:UIColor.gobalTextColor])
    }

    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
//        let cell = messagesCollectionView.dequeueReusableCell(withClass: PTChatCustomCell.self, for: indexPath)
//        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        return nil
    }

}

//MARK: MessageCellDelegate
extension PTChatViewController:MessageCellDelegate
{
    func didTapBackground(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("didTapBackground")
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        PTNSLogConsole("Avatar tapped")
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        let messageModel = self.messageList[indexPath?.section ?? 0]
        var vc:PTSettingListViewController!
        if messageModel.sender.senderId == PTChatData.share.bot.senderId
        {
            vc = PTSettingListViewController(user: PTChatData.share.bot)
            vc.currentChatModel = self.historyModel
        }
        else
        {
            vc = PTSettingListViewController(user: PTChatData.share.user)
        }
        self.navigationController?.pushViewController(vc)
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        self.messageInputBar.inputTextView.resignFirstResponder()
        
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        let messageModel = self.messageList[indexPath!.section]

        var titles:[String] = [String]()
        switch messageModel.kind {
        case .text( _):
            if messageModel.sender.senderId == PTChatData.share.bot.senderId
            {
                titles = [.copyString,.editString,.playString,.saveString]
            }
            else
            {
                titles = [.copyString,.editString,.resend]
            }
        default:
            break
        }
        
        self.messageInputBar.alpha = 0
        UIAlertController.baseActionSheet(title: PTLanguage.share.text(forKey: "alert_Option_title"), subTitle: PTLanguage.share.text(forKey: "alert_Select_option"),cancelButtonName: PTLanguage.share.text(forKey: "button_Cancel"), titles: titles) { sheet in
            
        } cancelBlock: { sheet in
            self.messageInputBar.alpha = 1
        } otherBlock: { sheet, index in
            self.messageInputBar.alpha = 1
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
                
                self.closeEditButton.isHidden = false
                self.closeEditButton.isUserInteractionEnabled = true
                self.voiceTypeButton.isHidden = true
                self.voiceTypeButton.isUserInteractionEnabled = false

                let type = AppDelegate.appDelegate()!.appConfig.getAIMpdelType(typeString: AppDelegate.appDelegate()!.appConfig.aiModelType)
                switch type {
                case .chat(.chatgpt),.chat(.chatgpt0301),.chat(.chatgpt4),.chat(.chatgpt40314),.chat(.chatgpt432k),.chat(.chatgpt432k0314):
                    break
                default:
                    switch messageModel.kind {
                    case .text(let text):
                        self.editString = text
                        self.messageInputBar.inputTextView.placeholder = String(format: PTLanguage.share.text(forKey: "chat_Edit"), self.editString)
                    default: break
                    }

                    self.editMessage = true
                    self.messageInputBar.inputTextView.becomeFirstResponder()
                }
            case .playString:
                switch messageModel.kind {
                case .text(let text):
                    if messageModel.sender.senderId == PTChatData.share.bot.senderId
                    {
                        self.speechKit.speakText(text)
                    }
                default: break
                }
            case .saveString:
                PTGCDManager.gcdAfter(time: 0.5) {
                    if messageModel.sender.senderId == PTChatData.share.bot.senderId
                    {
                        let userModel = self.messageList[indexPath!.section - 1]
                        UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "alert_Save_Q&A"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                            
                        } moreBtn: { index, title in
                            
                            let saveChatArr = AppDelegate.appDelegate()!.appConfig.getSaveChatData()
                            for saveModel in saveChatArr
                            {
                                if saveModel.questionDate == userModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss") && saveModel.answerDate == messageModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                {
                                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Error_same"))
                                    return
                                }
                            }
                            let model = PTChatModel()
                            
                            switch userModel.kind {
                            case .audio(let item):
                                model.questionType = 1
                                model.questionVoiceURL = item.url.lastPathComponent
                                self.speechKit.recognizeSpeech(filePath: URL(fileURLWithPath: item.url.absoluteString.replacingOccurrences(of: "file://", with: ""))) { text in
                                    model.question = text
                                }
                            case .text(let text):
                                model.questionType = 0
                                model.question = text
                            default:
                                break
                            }
                            model.questionDate = userModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                            
                            switch messageModel.kind {
                            case .photo(let item):
                                model.answerType = 1
                                model.answerImageURL = item.url!.absoluteString
                            case .text(let text):
                                model.answerType = 0
                                model.answer = text
                            default:
                                break
                            }
                            model.answerDate = messageModel.sentDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                            self.saveChatModelToJsonString(model: model)
                            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_success"))
                        }
                    }
                }
            default:
                break
            }
        } tapBackgroundBlock: { sheet in
            self.messageInputBar.alpha = 1
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
            let viewer = PTMediaViewer(viewConfig: config)
            viewer.showImageViewer()
            viewer.viewSaveImageBlock = { finish in
                if finish
                {
                    PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_success"))
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
            }
            else
            {
                self.audioPlayer.resumeSound()
            }
        }
        else
        {
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

    func didTapAccessoryView(in _: MessageCollectionViewCell) {
        PTNSLogConsole("Accessory view tapped")
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


extension PTChatViewController: InputBarAccessoryViewDelegate
{
    func drawImage(str:String,saveModel:PTChatModel)
    {
        Task{
            do{
                let result = try await self.openAI.getImages(with:str,imageSize: AppDelegate.appDelegate()!.appConfig.aiDrawSize)
                await MainActor.run{
                    
                    let imageURL = result.data.first?.url ?? URL(string: "")

                    let date = Date()

                    saveModel.answerDate = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                    saveModel.answerType = 1
                    saveModel.answerImageURL = imageURL?.absoluteString ?? ""

                    let message = PTMessageModel(imageURL: imageURL!, user: PTChatData.share.bot, messageId: UUID().uuidString, date: date)
                    self.insertMessage(message)

                    PTNSLogConsole(result.data.first?.url ?? "")
                    self.setTitleViewFrame(withModel: self.historyModel!)
                    self.chatModelToJsonString(model: saveModel)
                }
            }catch{
                PTGCDManager.gcdMain {
                    PTBaseViewController.gobal_drop(title: error.localizedDescription)
                    self.setTitleViewFrame(withModel: self.historyModel!)
                }
            }
        }
    }
    
    // MARK: Internal
    @objc func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        self.processInputBar(self.messageInputBar)
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
    private func insertMessages(_ data: [Any])
    {
        for component in data {
            let user = PTChatData.share.user
            let date = Date()
            if let str = component as? String {
                let saveModel = PTChatModel()
                saveModel.questionType = 0
                saveModel.question = str
                saveModel.questionDate = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")

                let message = PTMessageModel(text: str, user: user, messageId: UUID().uuidString, date: date)
                insertMessage(message)
                self.setTitleViewFrame(text: .thinking)
                switch self.chatCase {
                case .chat:
                    if self.editMessage {
                        self.openAI.sendEdits(with: str, input: self.editString) { result in
                            switch result {
                            case .success(let success):
                                
                                let botDate = Date()
                                
                                saveModel.answerDate = botDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
                                saveModel.answerType = 0
                                saveModel.answer = success.choices.first?.text ?? ""
                                
                                let botMessage = PTMessageModel(text: success.choices.first?.text ?? "", user: PTChatData.share.bot, messageId: UUID().uuidString, date: botDate)
                                self.insertMessage(botMessage)
                                PTGCDManager.gcdMain {
                                    self.editString = ""
                                    self.editMessage = false
                                    self.setTitleViewFrame(text: .thinking)
                                }
                                self.chatModelToJsonString(model: saveModel)
                            case .failure(let failure):
                                PTGCDManager.gcdMain {
                                    self.setTitleViewFrame(withModel: self.historyModel!)
                                    PTBaseViewController.gobal_drop(title: failure.localizedDescription)
                                }
                            }
                        }
                    } else {
                        if self.historyModel!.systemContent.stringIsEmpty() {
                            let type = AppDelegate.appDelegate()!.appConfig.getAIMpdelType(typeString: AppDelegate.appDelegate()!.appConfig.aiModelType)
                            switch type {
                            case .chat(.chatgpt),.chat(.chatgpt0301),.chat(.chatgpt4),.chat(.chatgpt40314),.chat(.chatgpt432k),.chat(.chatgpt432k0314):
                                let chat: [ChatMessage] = [
                                    ChatMessage(role: .user, content: str),
                                ]
                                self.openAI.sendChat(with: chat,model: type,maxTokens: 2048,temperature: AppDelegate.appDelegate()!.appConfig.aiSmart) { result in
                                    switch result {
                                    case .success(let success):
                                        self.saveQAndAText(question: success.choices.first?.message.content ?? "", saveModel: saveModel)
                                    case .failure(let failure):
                                        PTGCDManager.gcdMain {
                                            self.setTitleViewFrame(withModel: self.historyModel!)
                                            PTBaseViewController.gobal_drop(title: failure.localizedDescription)
                                        }
                                    }
                                }
                            default:
                                self.openAI.sendCompletion(with: str,model: type,maxTokens: 2048,temperature: AppDelegate.appDelegate()!.appConfig.aiSmart) { result in
                                    switch result {
                                    case .success(let success):
                                        self.saveQAndAText(question: success.choices.first?.text ?? "", saveModel: saveModel)
                                    case .failure(let failure):
                                        PTGCDManager.gcdMain {
                                            self.setTitleViewFrame(withModel: self.historyModel!)
                                            PTBaseViewController.gobal_drop(title: failure.localizedDescription)
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
                            let chat: [ChatMessage] = [
                                ChatMessage(role: .system, content: self.historyModel!.systemContent),
                                ChatMessage(role: .user, content: str)
                            ]
                            self.openAI.sendChat(with: chat,model: type,maxTokens: 2048,temperature: AppDelegate.appDelegate()!.appConfig.aiSmart) { result in
                                switch result {
                                case .success(let success):
                                    self.saveQAndAText(question: success.choices.first?.message.content ?? "", saveModel: saveModel)
                                case .failure(let failure):
                                    PTGCDManager.gcdMain {
                                        self.setTitleViewFrame(withModel: self.historyModel!)
                                        PTBaseViewController.gobal_drop(title: failure.localizedDescription)
                                    }
                                }
                            }

                        }
                    }
                default:
                    self.drawImage(str: str,saveModel: saveModel)
                }
            } else if let img = component as? UIImage {
                let message = PTMessageModel(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
    
    func saveQAndAText(question:String,saveModel:PTChatModel)
    {
        let botDate = Date()
        saveModel.answerDate = botDate.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        saveModel.answerType = 0
        saveModel.answer = question

        let botMessage = PTMessageModel(text: question, user: PTChatData.share.bot, messageId: UUID().uuidString, date: botDate)
        self.insertMessage(botMessage)
        PTGCDManager.gcdMain {
            self.setTitleViewFrame(withModel: self.historyModel!)
        }
        self.chatModelToJsonString(model: saveModel)
    }
}

//MARK: OSSSpeechDelegate
extension PTChatViewController:OSSSpeechDelegate
{
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
        if self.translateToText
        {
            self.maskView.translateLabel.text = text
            self.maskView.translateLabel.isHidden = false
            var textHeight = self.maskView.translateLabel.sizeFor(size: CGSize(width: CGFloat.kSCREEN_WIDTH - 40, height: CGFloat(MAXFLOAT))).height + 10
            
            let centerY = CGFloat.kSCREEN_HEIGHT / 2
            let textMaxHeight = (centerY - CGFloat.statusBarHeight() - 44 - 5)
            if textHeight >= textMaxHeight
            {
                textHeight = textMaxHeight
            }
            
            self.maskView.translateLabel.snp.updateConstraints { make in
                make.height.equalTo(textHeight)
            }
        }
        else
        {
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
        let voiceMessage = PTMessageModel(audioURL: voiceURL, user: PTChatData.share.user, messageId: UUID().uuidString, date: date)
        
        let saveModel = PTChatModel()
        if self.sendTranslateText
        {
            saveModel.questionType = 0
        }
        else
        {
            saveModel.questionType = 1
            saveModel.questionVoiceURL = voiceURL.lastPathComponent
        }
        saveModel.question = text
        saveModel.questionDate = date.dateFormat(formatString: "yyyy-MM-dd HH:mm:ss")
        if self.isSendVoice
        {
            self.isSendVoice = false
            if self.sendTranslateText
            {
                self.insertMessages([text])
                self.maskView.translateLabel.text = ""
            }
            else
            {
                self.sendVoiceMessage(text: text,saveModel: saveModel)
                self.insertMessage(voiceMessage)
            }
            self.messagesCollectionView.scrollToLastItem(animated: true)
            self.sendTranslateText = false
        }
        else
        {
            self.speechKit.deleteVoiceFolderItem(url: URL(fileURLWithPath: url.absoluteString.replacingOccurrences(of: "file://", with: "")))
        }
    }
}

//MARK: LXFEmptyDataSetable
extension PTChatViewController:LXFEmptyDataSetable
{
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

extension PTChatViewController
{
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}

extension PTChatViewController:UITextFieldDelegate {}

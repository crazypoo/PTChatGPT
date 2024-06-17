//
//  PTSettingViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import PooTools
import SnapKit
import SwifterSwift
import BRPickerView
import AttributedString

class PTSettingViewController: PTChatBaseViewController {

    var skipBlock:(()->Void)?
    
    var languageType:OSSVoiceEnum = .ChineseSimplified
    var currentSelectLanguage:String = OSSVoiceEnum.ChineseSimplified.rawValue
    
    lazy var languagePicker:BRStringPickerView = {
                
        let picker = BRStringPickerView(pickerMode: .componentSingle)
        picker.pickerStyle = PTAppConfig.gobal_BRPickerStyle()
        picker.title = PTAppConfig.languageFunc(text: "first_Select_speech_language")
        return picker
    }()
            
    lazy var speechLanAtt : UILabel = {
        let view = UILabel()
        return view
    }()
    
    lazy var token:PTTextField = {
        let view = PTTextField()
        view.placeholder = PTAppConfig.languageFunc(text: "first_Paste")
        view.delegate = self
        view.text = AppDelegate.appDelegate()?.appConfig.apiToken
        view.leftSpace = 10
        return view
    }()
    
    let lanAttMain:ASAttributedString = .init("语音输入母语",.paragraph(.alignment(.left)),.foreground(.lightGray),.font(.appfont(size: 14)))
        
    lazy var lanAttLabel:UILabel = {
        let view = UILabel()
        view.attributed.text = "\(wrap:self.lanAttMain) \(wrap:self.lanValueAtt(current: "默认中文(简体)"))"
        return view
    }()
    
    lazy var keyAttLabel:UILabel = {
        let view = UILabel()
        return view
    }()
    
    lazy var infoLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
        
    lazy var disclaimerButton:UILabel = {
        
        let att:ASAttributedString = ASAttributedString.init("\(PTAppConfig.languageFunc(text: "first_Disclaimer"))",.paragraph(.alignment(.center)),.foreground(.systemBlue),.font(.appfont(size: 14)),.action(self.disclaimerClick),.underline(.single,color: .systemBlue))
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributed.text = att
        return view
    }()
    
    lazy var gogogoButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(PTAppConfig.languageFunc(text: "first_Start"), for: .normal)
        button.setTitleColor(.gobalTextColor, for: .normal)
        button.addActionHandlers { sender in
            self.token.resignFirstResponder()
            self.checkTextField(textField: self.token)
        }
        return button
    }()
    
    lazy var disclaimerLabel : UILabel = {
        let view = UILabel()
        view.font = .appfont(size: 14)
        view.textColor = .lightGray
        view.text = PTAppConfig.languageFunc(text: "first_Disclaimer_info")
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    lazy var skipButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("跳过", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addActionHandlers { sender in
            self.dismiss(animated: true) {
                if self.skipBlock != nil {
                    self.skipBlock!()
                }
            }
        }
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTAppConfig.languageFunc(text: "first_Title")
                
        self.view.backgroundColor = .gobalBackgroundColor
        
        if AppDelegate.appDelegate()!.appConfig.apiToken.stringIsEmpty() {
            NotificationCenter.default.addObserver(self, selector: #selector(self.showURLNotifi(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdDetailDisplayNotification), object: nil)
        }

        self.view.addSubviews([self.infoLabel,self.token,self.keyAttLabel,self.skipButton,self.lanAttLabel,self.disclaimerButton,self.gogogoButton,self.disclaimerLabel])
        self.infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
        }
        
        self.infoLabel.attributed.text = """
        \(wrap: .embedding("""
        \(.image(UIImage(named: "Applaunch")!,.custom(size:.init(width:100,height:100))))
        
        \(kAppName!,.font(.appfont(size: 24,bold: true)))
        """
        ), .paragraph(.alignment(.center)))
        """
        
        // Do any additional setup after loading the view.
        self.token.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.height.equalTo(44)
            make.top.equalTo(self.infoLabel.snp.bottom).offset(10)
        }
        self.token.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)
        
        self.keyAttLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.token)
            make.top.equalTo(self.token.snp.bottom).offset(10)
        }
        self.keyAttLabel.attributed.text = """
        \("如果你没有API token",.paragraph(.alignment(.left)),.foreground(.lightGray),.font(.appfont(size: 14))) \("Get API token",.paragraph(.alignment(.left)),.foreground(.systemBlue),.action {
            self.token.resignFirstResponder()
            let url = URL(string: getApiUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        },.font(.appfont(size: 14)))
        """
        
        self.skipButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.top.equalToSuperview().inset(16)
        }
        
        self.lanAttLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.keyAttLabel)
            make.top.equalTo(self.keyAttLabel.snp.bottom).offset(20)
        }
        
        self.gogogoButton.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.height.equalTo(44)
            make.top.equalTo(self.lanAttLabel.snp.bottom).offset(20)
        }
        self.gogogoButton.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)
        
        self.disclaimerLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.gogogoButton.snp.bottom).offset(5)
        }
        
        self.disclaimerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(CGFloat.kTabbarSaveAreaHeight + 10)
            make.left.right.equalTo(self.infoLabel)
        }
    }
    
    @objc func showURLNotifi(notifi:Notification) {
        let urlString = (notifi.object as! [String:String])["URLS"]
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func checkTextField(textField:UITextField) {
        if (textField.text ?? "").stringIsEmpty() || !(textField.text ?? "").nsString.contains("sk-") {
            PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Token_error"))
        } else {
            AppDelegate.appDelegate()!.appConfig.apiToken = textField.text!
            AppDelegate.appDelegate()!.appConfig.language = self.languageType.rawValue
            self.dismiss(animated: true) {
                if self.skipBlock != nil {
                    self.skipBlock!()
                }
            }
        }
    }
    
    func lanValueAtt(current:String)->ASAttributedString {
        let attLan:ASAttributedString = ASAttributedString.init("\(current)",.paragraph(.alignment(.left)),.foreground(.systemBlue),.font(.appfont(size: 14)),.action(self.lanAttClick))
        return attLan
    }
    
    func lanAttClick() {
        self.token.resignFirstResponder()
        
        self.languagePicker.selectValue = self.currentSelectLanguage
        self.languagePicker.dataSourceArr = AppDelegate.appDelegate()!.appConfig.languagePickerData
        self.languagePicker.show()
        self.languagePicker.resultModelBlock = { route in
            self.currentSelectLanguage = OSSVoiceEnum.allCases[route!.index].rawValue
            self.languageType = OSSVoiceEnum.allCases[route!.index]
            AppDelegate.appDelegate()!.appConfig.language = self.languageType.rawValue
            self.lanAttLabel.attributed.text = "\(wrap:self.lanAttMain) \(wrap:self.lanValueAtt(current: self.currentSelectLanguage))"
        }
    }

    func disclaimerClick() {
        self.token.resignFirstResponder()
        let vc = PTDisclaimerViewController()
        let nav = PTNavController(rootViewController: vc)
        self.present(nav, animated: true)
    }
}

extension PTSettingViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.checkTextField(textField: textField)
        return true
    }
}

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

let uTokenKey = "UserToken"
let uLanguageKey = "UserLanguage"

class PTSettingViewController: PTChatBaseViewController {

    var languageType:OSSVoiceEnum = .ChineseSimplified
    var currentSelectLanguage:String = OSSVoiceEnum.ChineseSimplified.rawValue
    
    lazy var languagePicker:BRStringPickerView = {
        
        let pickerStyle = BRPickerStyle()
        pickerStyle.topCornerRadius = 10
        
        let picker = BRStringPickerView(pickerMode: .componentSingle)
        picker.pickerStyle = pickerStyle
        return picker
    }()
        
    lazy var selectLanguage:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Select your language defult:zh-CN", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addActionHandlers { sender in
            self.languagePicker.selectValue = self.currentSelectLanguage
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()!.appConfig.languagePickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                self.currentSelectLanguage = OSSVoiceEnum.allCases[route!.index].rawValue
                self.languageType = OSSVoiceEnum.allCases[route!.index]
                UserDefaults.standard.set(self.languageType, forKey: uLanguageKey)
                self.selectLanguage.setTitle(self.currentSelectLanguage, for: .normal)
            }
        }
        return button
    }()
    
    lazy var token:UITextField = {
        let view = UITextField()
        view.placeholder = "粘貼你嘅Token/Paste your Token/Pega tu token"
        view.delegate = self
        return view
    }()
    
    lazy var infoLabel:UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    lazy var getApiToken:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Get API token", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addActionHandlers { sender in
            let url = URL(string: getApiUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return button
    }()
    
    lazy var disclaimerButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Disclaimer", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addActionHandlers { sender in
            let vc = PTDisclaimerViewController()
            self.navigationController?.pushViewController(vc)
        }
        return button
    }()
    
    lazy var gogogoButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("開始使用", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addActionHandlers { sender in
            self.checkTextField(textField: self.token)
        }
        return button
    }()
    
    lazy var disclaimerLabel : UILabel = {
        let view = UILabel()
        view.text = "By continuing you agree to have read the disclaimer"
        view.textColor = .gobalTextColor
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = "獲取OpenAi Api key"
        
        self.view.backgroundColor = .white
        
        if AppDelegate.appDelegate()!.appConfig.apiToken.stringIsEmpty()
        {
            NotificationCenter.default.addObserver(self, selector: #selector(self.showURLNotifi(notifi:)), name: NSNotification.Name(rawValue: PLaunchAdDetailDisplayNotification), object: nil)
        }

        self.view.addSubviews([self.infoLabel,self.token,self.selectLanguage,self.getApiToken,self.disclaimerButton,self.gogogoButton,self.disclaimerLabel])
        self.infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total + 5)
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
        }
        self.infoLabel.attributedText = NSMutableAttributedString.sj.makeText({ make in
            make.append("To use the app, you must generate a token to access the OpenAI API.").font(.appfont(size: 13)).alignment(.left).textColor(.gobalTextColor)
            make.append("\nThis app was not made by OpeanAI. This is an independent and completely free project that connects to OpenAI's public API. The app is not affiliated with OpenAI in any way, and if OpenAI would like to request closure of the project they could contact me.").font(.appfont(size: 16,bold: true)).alignment(.left).textColor(.red)
        })
        
        // Do any additional setup after loading the view.
        self.token.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.height.equalTo(44)
            make.top.equalTo(self.infoLabel.snp.bottom).offset(10)
        }
        self.token.viewCorner(radius: 5,borderWidth: 1,borderColor: .black)
        
        self.selectLanguage.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.token.snp.bottom).offset(20)
        }
        
        self.getApiToken.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.selectLanguage.snp.bottom).offset(20)
        }
        
        self.gogogoButton.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.height.equalTo(44)
            make.top.equalTo(self.getApiToken.snp.bottom).offset(20)
        }
        
        self.disclaimerLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.gogogoButton.snp.bottom).offset(20)
        }
        
        self.disclaimerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(CGFloat.kTabbarHeight_Total + 5)
            make.left.right.equalTo(self.infoLabel)
        }
    }
    
    @objc func showURLNotifi(notifi:Notification)
    {
        let urlString = (notifi.object as! [String:String])["URLS"]
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func checkTextField(textField:UITextField)
    {
        if (textField.text ?? "").stringIsEmpty() || !(textField.text ?? "").nsString.contains("sk-")
        {
            PTBaseViewController.gobal_drop(title: "Token錯誤/Wrong Token/Token incorrecta")
        }
        else
        {
            let vc = PTChatViewController(token: textField.text!,language: self.languageType)
            let nav = PTNavController(rootViewController: vc)
            AppDelegate.appDelegate()!.window!.rootViewController = nav
            AppDelegate.appDelegate()!.window!.makeKeyAndVisible()            
            UserDefaults.standard.set(textField.text, forKey: uTokenKey)
        }
    }
}

extension PTSettingViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.checkTextField(textField: textField)
        return true
    }
}

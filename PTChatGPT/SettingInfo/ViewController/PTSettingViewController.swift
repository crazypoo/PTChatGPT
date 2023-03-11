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

class PTSettingViewController: PTChatBaseViewController {

    var languageType:OSSVoiceEnum = .ChineseSimplified
    var currentSelectLanguage:String = OSSVoiceEnum.ChineseSimplified.rawValue
    
    lazy var languagePicker:BRStringPickerView = {
                
        let picker = BRStringPickerView(pickerMode: .componentSingle)
        picker.pickerStyle = PTAppConfig.gobal_BRPickerStyle()
        picker.title = PTLanguage.share.text(forKey: "first_Select_speech_language")
        return picker
    }()
        
    lazy var selectLanguage:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(PTLanguage.share.text(forKey: "first_Select_speech_language"), for: .normal)
        button.setTitleColor(.gobalTextColor, for: .normal)
        button.addActionHandlers { sender in
            self.token.resignFirstResponder()
            
            self.languagePicker.selectValue = self.currentSelectLanguage
            self.languagePicker.dataSourceArr = AppDelegate.appDelegate()!.appConfig.languagePickerData
            self.languagePicker.show()
            self.languagePicker.resultModelBlock = { route in
                self.currentSelectLanguage = OSSVoiceEnum.allCases[route!.index].rawValue
                self.languageType = OSSVoiceEnum.allCases[route!.index]
                AppDelegate.appDelegate()!.appConfig.language = self.languageType.rawValue
                self.selectLanguage.setTitle(self.currentSelectLanguage, for: .normal)
            }
        }
        return button
    }()
    
    lazy var token:UITextField = {
        let view = UITextField()
        view.placeholder = PTLanguage.share.text(forKey: "first_Paste")
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
        button.setTitle(PTLanguage.share.text(forKey: "first_Go_get_api_token"), for: .normal)
        button.setTitleColor(.gobalTextColor, for: .normal)
        button.addActionHandlers { sender in
            self.token.resignFirstResponder()
            let url = URL(string: getApiUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return button
    }()
    
    lazy var disclaimerButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(PTLanguage.share.text(forKey: "first_Disclaimer"), for: .normal)
        button.setTitleColor(.gobalTextColor, for: .normal)
        button.addActionHandlers { sender in
            self.token.resignFirstResponder()
            let vc = PTDisclaimerViewController()
            self.navigationController?.pushViewController(vc)
        }
        return button
    }()
    
    lazy var gogogoButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(PTLanguage.share.text(forKey: "first_Start"), for: .normal)
        button.setTitleColor(.gobalTextColor, for: .normal)
        button.addActionHandlers { sender in
            self.token.resignFirstResponder()
            self.checkTextField(textField: self.token)
        }
        return button
    }()
    
    lazy var disclaimerLabel : UILabel = {
        let view = UILabel()
        view.text = PTLanguage.share.text(forKey: "first_Disclaimer_info")
        view.textColor = .lightText
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTLanguage.share.text(forKey: "first_Title")
        
        self.view.backgroundColor = .gobalBackgroundColor
        
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
            make.append(PTLanguage.share.text(forKey: "first_Info_title")).font(.appfont(size: 13)).alignment(.left).textColor(.gobalTextColor)
            make.append("\n\(PTLanguage.share.text(forKey: "first_Info_info"))").font(.appfont(size: 16,bold: true)).alignment(.left).textColor(.red)
        })
        
        // Do any additional setup after loading the view.
        self.token.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.height.equalTo(44)
            make.top.equalTo(self.infoLabel.snp.bottom).offset(10)
        }
        self.token.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)
        
        var selectHeight = self.selectLanguage.sizeFor(size: CGSize(width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2, height: CGFloat(MAXFLOAT))).height
        if selectHeight < 44
        {
            selectHeight = 44
        }
        self.selectLanguage.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.token.snp.bottom).offset(20)
            make.height.equalTo(selectHeight)
        }
        self.selectLanguage.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)

        self.getApiToken.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.selectLanguage.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        self.getApiToken.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)

        self.gogogoButton.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.height.equalTo(44)
            make.top.equalTo(self.getApiToken.snp.bottom).offset(20)
        }
        self.gogogoButton.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)
        
        self.disclaimerLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.infoLabel)
            make.top.equalTo(self.gogogoButton.snp.bottom).offset(20)
        }
        
        self.disclaimerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(CGFloat.kTabbarHeight_Total + 5)
            make.left.right.equalTo(self.infoLabel)
            make.height.equalTo(44)
        }
        self.disclaimerButton.viewCorner(radius: 5,borderWidth: 1,borderColor: .gobalTextColor)
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
            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Token_error"))
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

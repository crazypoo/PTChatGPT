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

class PTSettingViewController: PTBaseViewController {

    var languageType:OSSVoiceEnum = .ChineseSimplified
    var currentSelectLanguage:String = OSSVoiceEnum.ChineseSimplified.rawValue
    
    lazy var languagePicker:BRStringPickerView = {
        
        let pickerStyle = BRPickerStyle()
        pickerStyle.topCornerRadius = 10
        
        let picker = BRStringPickerView(pickerMode: .componentSingle)
        picker.pickerStyle = pickerStyle
        return picker
    }()
    
    lazy var pickerData:[String] = {
        var data = [String]()
        OSSVoiceEnum.allCases.enumerated().forEach { index,value in
            data.append(value.rawValue)
        }
        return data
    }()
    
    lazy var selectLanguage:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Select your language defult:zh-CN", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addActionHandlers { sender in
            self.languagePicker.selectValue = self.currentSelectLanguage
            self.languagePicker.dataSourceArr = self.pickerData
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.view.addSubviews([self.token,self.selectLanguage])
        // Do any additional setup after loading the view.
        self.token.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        self.token.viewCorner(radius: 5,borderWidth: 1,borderColor: .black)
        
        self.selectLanguage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.token.snp.bottom).offset(20)
        }
    }
}

extension PTSettingViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text ?? "").stringIsEmpty() || !(textField.text ?? "").nsString.contains("sk-")
        {
            PTBaseViewController.gobal_drop(title: "Token錯誤/Wrong Token/Token incorrecta")
        }
        else
        {
            let vc = PTChatViewController(token: textField.text!,language: self.languageType)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true,completion: {
                AppDelegate.appDelegate()?.window?.bringSubviewToFront(AppDelegate.appDelegate()!.devFunction.mn_PFloatingButton!)
            })
            
            UserDefaults.standard.set(textField.text, forKey: uTokenKey)
        }
        return true
    }
}

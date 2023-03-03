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

class PTSettingViewController: PTBaseViewController {

    lazy var token:UITextField = {
        let view = UITextField()
        view.placeholder = "粘貼你嘅Token/Paste your Token/Pega tu token"
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.view.addSubviews([self.token])
        // Do any additional setup after loading the view.
        self.token.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        self.token.viewCorner(radius: 5,borderWidth: 1,borderColor: .black)
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
            let vc = PTChatViewController(token: textField.text!)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true)
            
            UserDefaults.standard.set(textField.text, forKey: "UserToken")
        }
        return true
    }
}

//
//  PTDiffusionViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 8/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import SwiftSpinner
import TextFieldEffects
import KDCircularProgress

@available(iOS 15.4, *)
class PTDiffusionViewController: PTChatBaseViewController {

    let dispatchQueue = DispatchQueue(label: "Generation")
    
    let diffusion = PTSableDiffusion(saveMemoryButBeSlower: true)
    
    lazy var showImageView : UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var promptString = ""
    
    lazy var promptText : HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = "主要内容"
        view.borderInactiveColor = .lightGray
        view.borderActiveColor = .orange
        view.placeholderColor = .lightGray
        view.clearButtonMode = .whileEditing
        view.textColor = .gobalTextColor
        view.delegate = self
        return view
    }()
    
    var negativeString = ""
    //MARK: 扩展字段
    ///扩展字段,这里是添加AI避免的操作(Option)
    lazy var negativeText : HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = "请输入你须要AI注意的地方"
        view.borderInactiveColor = .lightGray
        view.borderActiveColor = .orange
        view.placeholderColor = .lightGray
        view.clearButtonMode = .whileEditing
        view.textColor = .gobalTextColor
        view.delegate = self
        return view
    }()
    
    lazy var accuracyTitle:UILabel = {
        let view = UILabel()
        view.font = .appfont(size: 14)
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        view.numberOfLines = 0
        view.text = "精准度"
        return view
    }()
    
    var accuracyValue:Float = 10
    
    lazy var accuracySlider:PTSlider = {
        let slider = PTSlider(showTitle: true, titleIsValue: true)
        slider.maximumValue = 20
        slider.minimumValue = 1
        slider.value = self.accuracyValue
        slider.tintColor = .orange
        slider.titleColor = .orange
        slider.addSliderAction { sender in
            self.accuracyValue = sender.value
        }
        return slider
    }()

    lazy var stepTitle:UILabel = {
        let view = UILabel()
        view.font = .appfont(size: 14)
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        view.numberOfLines = 0
        view.text = "绘画步骤"
        return view
    }()

    var stepValue:Float = 20

    lazy var createStepSlider:PTSlider = {
        let slider = PTSlider(showTitle: true, titleIsValue: true)
        slider.maximumValue = 150
        slider.minimumValue = 20
        slider.value = self.stepValue
        slider.tintColor = .orange
        slider.titleColor = .orange
        slider.addSliderAction { sender in
            self.stepValue = sender.value
        }
        return slider
    }()
    
    lazy var createButton:UIButton = {
        let view = UIButton(type: .custom)
        view.titleLabel?.font = .appfont(size: 18,bold: true)
        view.setTitle("生成图片", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .orange
        view.setBackgroundImage(UIColor.orange.createImageWithColor().transformImage(size: CGSize(width: CGFloat.kSCREEN_WIDTH, height: 64)), for: .normal)
        view.setBackgroundImage(UIColor.lightGray.createImageWithColor().transformImage(size: CGSize(width: CGFloat.kSCREEN_WIDTH, height: 64)), for: .selected)
        view.addActionHandlers { sender in
            self.promptText.resignFirstResponder()
            self.negativeText.resignFirstResponder()
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                if self.promptString.stringIsEmpty() {
                    PTGCDManager.gcdMain {
                        PTBaseViewController.gobal_drop(title: "请输入需求")
                        sender.isUserInteractionEnabled = true
                        sender.isSelected = !sender.isSelected
                    }
                } else {
                    PTGCDManager.gcdBackground {
                        PTGCDManager.gcdMain {
                            sender.isUserInteractionEnabled = false
                        }
                    }
                    
                    self.dispatchQueue.async {
                        self.diffusion.generate(prompt: self.promptString, negativePrompt: self.negativeString, seed: Int.random(in: 1..<Int.max), steps: Int(self.stepValue), guidanceScale: self.accuracyValue) { image, progress, info in
                            
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    self.progress.angle = (Double(progress) * 360)
                                    sender.setTitle(info, for: .selected)
                                }
                            }
                            
                            PTNSLogConsole("当前进度\(progress)\n输出信息\(info)")
                            if image != nil {
                                PTGCDManager.gcdBackground {
                                    PTGCDManager.gcdMain {
                                        self.showImageView.image = UIImage(cgImage: image!)
                                    }
                                }
                                
                                if progress >= 1 {
                                    PTGCDManager.gcdBackground {
                                        PTGCDManager.gcdMain {
                                            sender.setTitle("", for: .selected)
                                            sender.isSelected = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        view.isSelected = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var progress :KDCircularProgress = {
        let view = KDCircularProgress()
        view.set(colors: UIColor.green)
        view.startAngle = -90
        view.progressThickness = 0.2
        view.trackThickness = 0.6
        view.clockwise = true
        view.trackColor = .lightGray
        view.gradientRotateSpeed = 2
        view.roundedCorners = false
        view.glowMode = .forward
        view.glowAmount = 0.9
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.dispatchQueue.async {
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    SwiftSpinner.show("正在初始化画家........")
                }
            }
            self.diffusion.initModels { progress, step in
                PTGCDManager.gcdBackground {
                    PTGCDManager.gcdMain {
                        SwiftSpinner.show("\(step)")
                    }
                }
                if progress >= 1 {
                    PTGCDManager.gcdAfter(time: 1) {
                        PTGCDManager.gcdBackground {
                            PTGCDManager.gcdMain {
                                SwiftSpinner.hide()
                            }
                        }
                    }
                }
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.addSubviews([self.showImageView,self.promptText,self.negativeText,self.accuracySlider,self.accuracyTitle,self.createStepSlider,self.stepTitle,self.createButton,self.progress])
        self.showImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total + 10)
            make.left.right.equalToSuperview().inset(5)
            make.height.equalTo(self.showImageView.snp.width)
        }
        self.showImageView.viewCorner(borderWidth: 1,borderColor: .lightGray)
        
        self.promptText.snp.makeConstraints { make in
            make.top.equalTo(self.showImageView.snp.bottom).offset(10)
            make.left.right.equalTo(self.showImageView)
            make.height.equalTo(54)
        }
        
        self.negativeText.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.promptText)
            make.top.equalTo(self.promptText.snp.bottom).offset(10)
        }
        
        self.accuracySlider.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.left.equalToSuperview().inset(100)
            make.top.equalTo(self.negativeText.snp.bottom).offset(10)
            make.height.equalTo(64)
        }
        
        self.accuracyTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(self.accuracySlider.snp.left)
            make.top.bottom.equalTo(self.accuracySlider)
        }
        
        self.createStepSlider.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.accuracySlider)
            make.top.equalTo(self.accuracySlider.snp.bottom).offset(10)
        }
        
        self.stepTitle.snp.makeConstraints { make in
            make.left.right.equalTo(self.accuracyTitle)
            make.top.bottom.equalTo(self.createStepSlider)
        }
        
        self.createButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.left.equalToSuperview().inset(0)
            make.top.equalTo(self.createStepSlider.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(CGFloat.kTabbarSaveAreaHeight + 10)
        }

        self.viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.createButton.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(self.createButton.frame.height + 20)
        }
        
        self.progress.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(self.createButton.snp.left).offset(-10)
            make.top.bottom.equalTo(self.createButton)
        }
    }
}

@available(iOS 15.4, *)
extension  PTDiffusionViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.promptText {
            self.promptString = textField.text ?? ""
        } else if textField == self.negativeText {
            self.negativeString = textField.text ?? ""
        }
    }
}

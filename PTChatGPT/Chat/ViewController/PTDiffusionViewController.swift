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

    var drawImageSize = AppDelegate.appDelegate()!.appConfig.aiDrawSize
    
    let dispatchQueue = DispatchQueue(label: "Generation")
    
    var referenceImage:CGImage?
    
    var diffusion : PTSableDiffusion?
    
    var modelName:String = "bins1_4"
    
    lazy var showImageView : UIButton = {
        let view = UIButton(type: .custom)
        view.isUserInteractionEnabled = false
        view.addActionHandlers { sender in
            let viewerModel = PTViewerModel()
            viewerModel.imageURL = self.showImageView.imageView!.image!
            viewerModel.imageShowType = .Normal
            let config = PTViewerConfig()
            config.actionType = .Save
            config.closeViewerImage = UIImage(systemName: "chevron.left")!.withTintColor(.white, renderingMode: .automatic)
            config.moreActionImage = UIImage(systemName: "ellipsis")!.withRenderingMode(.automatic)
            config.mediaData = [viewerModel]
            config.moreActionEX = ["Reset"]
            let viewer = PTMediaViewer(viewConfig: config)
            viewer.showImageViewer()
            viewer.viewSaveImageBlock = { finish in
                if finish {
                    PTGCDManager.gcdBackground {
                        PTGCDManager.gcdMain {
                            PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Save_success"))
                        }
                    }
                }
            }
            viewer.viewMoreActionBlock = { index in
                self.showImageView.setImage(UIImage(), for: .normal)
            }
            viewer.viewerDismissBlock = {
            }
        }
        return view
    }()
    
    var promptString = ""
    
    lazy var promptText : HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = PTLanguage.share.text(forKey: "diffusion_Prompt")
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
        view.placeholder = PTLanguage.share.text(forKey: "diffusion_Attention")
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
        view.text = PTLanguage.share.text(forKey: "diffusion_Accuracy")
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
        view.text = PTLanguage.share.text(forKey: "diffusion_Draw_step")
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
        view.setTitle(PTLanguage.share.text(forKey: "diffusion_Draw"), for: .normal)
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
                        PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "diffusion_Prompt"))
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
                        PTGCDManager.gcdBackground {
                            PTGCDManager.gcdMain {
                                SwiftSpinner.show(PTLanguage.share.text(forKey: "diffusion_Init"))
                            }
                        }
                        self.diffusion = PTSableDiffusion(modelName: self.modelName,saveMemoryButBeSlower: true)
                        self.diffusion?.initModels { progress, step in
                            PTGCDManager.gcdBackground {
                                PTGCDManager.gcdMain {
                                    SwiftSpinner.show("\(step)")
                                }
                            }
                            if progress >= 1 {
                                PTGCDManager.gcdAfter(time: 1) {
                                    PTGCDManager.gcdBackground {
                                        PTGCDManager.gcdMain {
                                            SwiftSpinner.hide {
                                                self.dispatchQueue.async {
                                                    self.diffusion!.generate(prompt: self.promptString, negativePrompt: self.negativeString, seed: Int.random(in: 1..<Int.max), steps: Int(self.stepValue), guidanceScale: self.accuracyValue/*,imgGuidance:self.referenceImage*/) { image, progress, info in
                                                        
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
                                                                    self.showImageView.setImage(UIImage(cgImage: image!), for: .normal)
                                                                }
                                                            }
                                                            
                                                            if progress >= 1 {
                                                                PTGCDManager.gcdBackground {
                                                                    PTGCDManager.gcdMain {
                                                                        self.referenceImage = nil
                                                                        self.progress.angle = 0
                                                                        self.showImageView.isUserInteractionEnabled = true
                                                                        sender.setTitle("", for: .selected)
                                                                        sender.isSelected = false
                                                                        sender.isUserInteractionEnabled = true
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
        view.set(colors: UIColor.orange)
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
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.zx_navTitle = "Stable Diffusion"
        
        let moreButton = BKLayoutButton()
        moreButton.setMidSpacing(5)
        moreButton.titleLabel?.font = .appfont(size: 14,bold: true)
        moreButton.setTitleColor(.gobalTextColor, for: .normal)
        moreButton.setTitle("v1.4", for: .normal)
        moreButton.setTitle("v1.5", for: .selected)
        moreButton.layoutStyle = .leftImageRightTitle
        moreButton.setImage(UIImage(systemName: "chevron.up.chevron.down")!.withRenderingMode(.automatic), for: .normal)
        moreButton.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.modelName = "bins1_4"
            } else {
                self.modelName = "bins1_5"
            }
        }
        moreButton.isSelected = true
//        let photoImage = UIButton(type: .custom)
//        photoImage.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill")?.withTintColor(.gobalTextColor, renderingMode: .automatic), for: .normal)
//        photoImage.addActionHandlers { sender in
//            PTGCDManager.gcdAfter(time: 0.35) {
//                Task.init {
//                    do {
//                        let object:UIImage = try await PTImagePicker.openAlbum()
//                        var image = object.transformImage(size: AppDelegate.appDelegate()!.appConfig.aiDrawSize)
//                        self.showImageView.setImage(object, for: .normal)
//                        self.referenceImage = self.resize(image.cgImage!)
//                    } catch let pickerError as PTImagePicker.PickerError {
//                        pickerError.outPutLog()
//                    }
//                }
//            }
//        }
        self.zx_navBar?.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.height.equalTo(34)
            make.bottom.equalToSuperview().inset(5)
        }
        
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
    
    private func resize(_ image: CGImage) -> CGImage? {
        let w = self.drawImageSize.width
        let h = self.drawImageSize.height
        var ratio: Float = 0.0
        let imageWidth = Float(image.width)
        let imageHeight = Float(image.height)
        let maxWidth: Float = Float(w)/8
        let maxHeight: Float = Float(h)/8
        
        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            ratio = maxWidth / imageWidth
        } else {
            ratio = maxHeight / imageHeight
        }
        
        // Calculate new size based on the ratio
        if ratio > 1 {
            ratio = 1
        }
        
        let width = imageWidth * ratio
        let height = imageHeight * ratio
        
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue).rawValue) else { return nil }
        
        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))
        
        // extract resulting image from context
        return context.makeImage()
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

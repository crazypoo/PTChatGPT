//
//  PTColorSettingViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import ChromaColorPicker

class PTColorSettingViewController: PTChatBaseViewController {

    let colorPicker = ChromaColorPicker()
    let brightnessSlider = ChromaBrightnessSlider()
    var userBubbleHandle = ChromaColorHandle()
    var botBubbleHandle = ChromaColorHandle()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        
        self.zx_navTitle = "顏色設置"
        self.setupColorPicker()
        self.setupBrightnessSlider()
        self.setupColorPickerHandles()
        
        self.view.addSubviews([self.colorPicker,self.brightnessSlider])
        self.colorPicker.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(self.colorPicker.snp.width)
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total + 10)
        }
        self.brightnessSlider.snp.makeConstraints { make in
            make.left.right.equalTo(self.colorPicker)
            make.height.equalTo(28)
            make.top.equalTo(self.colorPicker.snp.bottom).offset(20)
        }
    }
    
    func setupColorPicker()
    {
        self.colorPicker.delegate = self
        self.colorPicker.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupBrightnessSlider() {
        self.brightnessSlider.connect(to: self.colorPicker)
        self.brightnessSlider.trackColor = UIColor.blue
        self.brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupColorPickerHandles()
    {
        self.userBubbleHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.userBubbleColor)

        let userBubbleImageView = UIImageView(image: UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate))
        userBubbleImageView.contentMode = .scaleAspectFit
        userBubbleImageView.tintColor = .white
        self.userBubbleHandle.accessoryView = userBubbleImageView
        self.userBubbleHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
        
        self.botBubbleHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.botBubbleColor)
        let botBubbleImageView = UIImageView(image: UIImage(systemName: "bubble.right.fill")?.withRenderingMode(.alwaysTemplate))
        botBubbleImageView.contentMode = .scaleAspectFit
        botBubbleImageView.tintColor = .white
        self.botBubbleHandle.accessoryView = botBubbleImageView
        self.botBubbleHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
    }
}

extension PTColorSettingViewController:ChromaColorPickerDelegate
{
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        if handle == self.botBubbleHandle
        {
            AppDelegate.appDelegate()?.appConfig.botBubbleColor = color
            UserDefaults.standard.set(color.toHexString, forKey: uBotBubbleColor)
        }
        else if handle == self.userBubbleHandle
        {
            AppDelegate.appDelegate()?.appConfig.userBubbleColor = color
            UserDefaults.standard.set(color.toHexString, forKey: uUserBubbleColor)
        }
    }
}

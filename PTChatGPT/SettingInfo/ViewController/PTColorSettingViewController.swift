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
    var userTextHandle = ChromaColorHandle()
    var botTextHandle = ChromaColorHandle()
    var waveHandle = ChromaColorHandle()

    lazy var aboutModels : [PTSettingModels] = {
        let colorMain = PTSettingModels()
        colorMain.name = PTLanguage.share.text(forKey: "alert_Info")
        
        let userBubbleInfo = PTFusionCellModel()
        userBubbleInfo.name = PTLanguage.share.text(forKey: "color_Bubble_user")
        userBubbleInfo.nameColor = .gobalTextColor
        userBubbleInfo.leftImage = UIImage(systemName: "bubble.left.fill")!.withRenderingMode(.automatic)
        
        let botBubbleInfo = PTFusionCellModel()
        botBubbleInfo.name = PTLanguage.share.text(forKey: "color_Bubble_bot")
        botBubbleInfo.nameColor = .gobalTextColor
        botBubbleInfo.leftImage = UIImage(systemName: "bubble.right.fill")!.withRenderingMode(.automatic)
        
        let userTextInfo = PTFusionCellModel()
        userTextInfo.name = PTLanguage.share.text(forKey: "color_Text_user")
        userTextInfo.nameColor = .gobalTextColor
        userTextInfo.leftImage = UIImage(systemName: "plus.bubble.fill")!.withRenderingMode(.automatic)
        
        let botTextInfo = PTFusionCellModel()
        botTextInfo.name = PTLanguage.share.text(forKey: "color_Text_bot")
        botTextInfo.nameColor = .gobalTextColor
        botTextInfo.leftImage = UIImage(systemName: "text.bubble.fill")!.withRenderingMode(.automatic)

        let waveInfo = PTFusionCellModel()
        waveInfo.name = PTLanguage.share.text(forKey: "color_Wave")
        waveInfo.nameColor = .gobalTextColor
        waveInfo.leftImage = UIImage(systemName: "waveform")!.withRenderingMode(.automatic)

        if self.user.senderId == PTChatData.share.bot.senderId {
            colorMain.models = [botBubbleInfo,botTextInfo]
        } else if self.user.senderId == PTChatData.share.user.senderId {
            colorMain.models = [userBubbleInfo,userTextInfo,waveInfo]
        } else {
            colorMain.models = [userBubbleInfo,botBubbleInfo,userTextInfo,botTextInfo,waveInfo]
        }
        
        return [colorMain]
    }()
                
    var mSections = [PTSection]()
    func comboLayout()->UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout.init { section, environment in
            self.generateSection(section: section)
        }
        layout.register(PTBaseDecorationView_Corner.self, forDecorationViewOfKind: "background")
        layout.register(PTBaseDecorationView.self, forDecorationViewOfKind: "background_no")
        return layout
    }
    
    func generateSection(section:NSInteger)->NSCollectionLayoutSection {
        let sectionModel = mSections[section]

        var group : NSCollectionLayoutGroup
        let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
        
        var bannerGroupSize : NSCollectionLayoutSize
        var customers = [NSCollectionLayoutGroupCustomItem]()
        var groupH:CGFloat = 0
        var cellHeight:CGFloat = 0
        var screenW:CGFloat = 0
        if Gobal_device_info.isPad {
            cellHeight = 64
            screenW = 400
        } else {
            cellHeight = CGFloat.ScaleW(w: 54)
            screenW = CGFloat.kSCREEN_WIDTH
        }
        sectionModel.rows.enumerated().forEach { (index,model) in
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: screenW - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
            customers.append(customItem)
            groupH += cellHeight
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
        group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
            customers
        })
        
        var sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        var laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        sectionInsets = NSDirectionalEdgeInsets.init(top: 10, leading: 0, bottom: 0, trailing: 0)
        laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        let backItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        backItem.contentInsets = NSDirectionalEdgeInsets.init(top: 10, leading: PTAppBaseConfig.share.defaultViewSpace, bottom: 0, trailing: PTAppBaseConfig.share.defaultViewSpace)
        laySection.decorationItems = [backItem]
        
        laySection.supplementariesFollowContentInsets = false

        return laySection
    }

    lazy var collectionView : UICollectionView = {
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: self.comboLayout())
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    init(user:PTChatUser) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zx_navTitle = PTLanguage.share.text(forKey: "color_Setting")
        if Gobal_device_info.isPad {
            self.isModalInPresentation = true
            self.zx_navFixFrame = CGRect(x: 0, y: 0, width: 400, height: 54)
        }
        self.setupColorPicker()
        self.setupBrightnessSlider()
        self.setupColorPickerHandles()
        
        self.view.addSubviews([self.colorPicker,self.brightnessSlider,self.collectionView])
        self.colorPicker.snp.makeConstraints { make in
            if Gobal_device_info.isPad {
                make.left.right.equalToSuperview().inset(88)
            } else {
                make.left.right.equalToSuperview().inset(30)
            }
            make.height.equalTo(self.colorPicker.snp.width)
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total + 10)
        }
        self.brightnessSlider.snp.makeConstraints { make in
            make.left.right.equalTo(self.colorPicker)
            make.height.equalTo(28)
            make.top.equalTo(self.colorPicker.snp.bottom).offset(20)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.brightnessSlider.snp.bottom)
        }
                
        if Gobal_device_info.isPad {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: nil)
            panGestureRecognizer.delegate = self
            self.colorPicker.addGestureRecognizer(panGestureRecognizer)
        }

        self.showDetail()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func showDetail() {
        mSections.removeAll()

        self.aboutModels.enumerated().forEach { (index,value) in
            var rows = [PTRows]()
            value.models.enumerated().forEach { (subIndex,subValue) in
                let row_List = PTRows.init(title: subValue.name, placeholder: subValue.content,cls: PTFusionCell.self, ID: PTFusionCell.ID, dataModel: subValue)
                rows.append(row_List)
            }
            let cellSection = PTSection.init(rows: rows)
            mSections.append(cellSection)
        }
        
        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }

    func setupColorPicker() {
        self.colorPicker.delegate = self
        self.colorPicker.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupBrightnessSlider() {
        self.brightnessSlider.connect(to: self.colorPicker)
        self.brightnessSlider.trackColor = UIColor.blue
        self.brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
    }

    func botColorSet() {
        self.botBubbleHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.botBubbleColor)
        let botBubbleImageView = UIImageView(image: UIImage(systemName: "bubble.right.fill")?.withRenderingMode(.alwaysTemplate))
        botBubbleImageView.contentMode = .scaleAspectFit
        botBubbleImageView.tintColor = .white
        self.botBubbleHandle.accessoryView = botBubbleImageView
        self.botBubbleHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)

        self.botTextHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.botTextColor)
        let botTextImageView = UIImageView(image: UIImage(systemName: "text.bubble.fill")?.withRenderingMode(.alwaysTemplate))
        botTextImageView.contentMode = .scaleAspectFit
        botTextImageView.tintColor = .white
        self.botTextHandle.accessoryView = botTextImageView
        self.botTextHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
    }
    
    func userColorSet() {
        self.userBubbleHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.userBubbleColor)
        let userBubbleImageView = UIImageView(image: UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.automatic))
        userBubbleImageView.contentMode = .scaleAspectFit
        userBubbleImageView.tintColor = .white
        self.userBubbleHandle.accessoryView = userBubbleImageView
        self.userBubbleHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)

        self.userTextHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.userTextColor)
        let userTextImageView = UIImageView(image: UIImage(systemName: "plus.bubble.fill")?.withRenderingMode(.alwaysTemplate))
        userTextImageView.contentMode = .scaleAspectFit
        userTextImageView.tintColor = .white
        self.userTextHandle.accessoryView = userTextImageView
        self.userTextHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)

        self.waveHandle = self.colorPicker.addHandle(at: AppDelegate.appDelegate()!.appConfig.waveColor)
        let waveImageView = UIImageView(image: UIImage(systemName: "waveform")?.withRenderingMode(.alwaysTemplate))
        waveImageView.contentMode = .scaleAspectFit
        waveImageView.tintColor = .white
        self.waveHandle.accessoryView = waveImageView
        self.waveHandle.accessoryViewEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
    }
    
    func setupColorPickerHandles() {
        if self.user.senderId == PTChatData.share.bot.senderId {
            self.botColorSet()
        } else if self.user.senderId == PTChatData.share.user.senderId {
            self.userColorSet()
        } else {
            self.userColorSet()
            self.botColorSet()
        }
    }
    
    func createImageInfo(image:UIImage,info:String)->BKLayoutButton {
        let view = BKLayoutButton()
        view.setImage(image, for: .normal)
        view.layoutStyle = .leftImageRightTitle
        view.setMidSpacing(CGFloat.ScaleW(w: 5))
        view.setImageSize(CGSize(width: 18, height: 15))
        view.titleLabel?.font = .appfont(size: 14)
        view.setTitleColor(.gobalTextColor, for: .normal)
        view.setTitle(info, for: .normal)
        view.isUserInteractionEnabled = false
        return view
    }
}

extension PTColorSettingViewController:ChromaColorPickerDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        if handle == self.botBubbleHandle {
            AppDelegate.appDelegate()?.appConfig.botBubbleColor = color
        } else if handle == self.userBubbleHandle {
            AppDelegate.appDelegate()?.appConfig.userBubbleColor = color
        } else if handle == self.userTextHandle {
            AppDelegate.appDelegate()?.appConfig.userTextColor = color
        } else if handle == self.botTextHandle {
            AppDelegate.appDelegate()?.appConfig.botTextColor = color
        } else if handle == self.waveHandle {
            AppDelegate.appDelegate()?.appConfig.waveColor = color
        }
    }
}

extension PTColorSettingViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTFusionCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.topLineView.isHidden = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
}

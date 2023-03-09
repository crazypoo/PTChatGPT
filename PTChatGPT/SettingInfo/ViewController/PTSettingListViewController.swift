//
//  PTSettingListViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

fileprivate extension String
{
    //MARK: 主題
    static let colorString = PTLanguage.share.text(forKey: "about_Color")
    static let languageString = PTLanguage.share.text(forKey: "about_Language")
    static let themeString = PTLanguage.share.text(forKey: "about_Theme")
    //MARK: 聊天相關
    static let savedChat = PTLanguage.share.text(forKey: "about_SavedChat")
    static let deleteAllChat = PTLanguage.share.text(forKey: "about_DeleteAllChat")
    //MARK: API
    static let apiAIType = PTLanguage.share.text(forKey: "about_APIAIType")
    static let apiAIToken = PTLanguage.share.text(forKey: "about_APIAIToken")
    static let getAPIAIToken = PTLanguage.share.text(forKey: "about_GetAPIAIToken")
    //MARK: Other
    static let github = PTLanguage.share.text(forKey: "about_Github")
    static let forum = PTLanguage.share.text(forKey: "about_Forum")
    static let rate = PTLanguage.share.text(forKey: "about_Rate")
    static let version = PTLanguage.share.text(forKey: "about_Version")

}

class PTSettingListViewController: PTChatBaseViewController {

    var aboutModels : [PTSettingModels] = {
        
        let disclosureIndicatorImageName = UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal)
        
        let themeMain = PTSettingModels()
        themeMain.name = "主題"
        
        //MARK: 主題
        let color = PTFunctionCellModel()
        color.name = .colorString
        color.haveDisclosureIndicator = true
        color.nameColor = .gobalTextColor
        color.disclosureIndicatorImageName = disclosureIndicatorImageName

        let language = PTFunctionCellModel()
        language.name = .languageString
        language.haveDisclosureIndicator = true
        language.nameColor = .gobalTextColor
        language.disclosureIndicatorImageName = disclosureIndicatorImageName

        let theme = PTFunctionCellModel()
        theme.name = .themeString
        theme.haveDisclosureIndicator = true
        theme.nameColor = .gobalTextColor
        theme.disclosureIndicatorImageName = disclosureIndicatorImageName
        
        themeMain.models = [color,language,theme]
        
        let chatMain = PTSettingModels()
        chatMain.name = "Chat"

        //MARK: Chat
        let savedMessage = PTFunctionCellModel()
        savedMessage.name = .savedChat
        savedMessage.haveDisclosureIndicator = true
        savedMessage.nameColor = .gobalTextColor
        savedMessage.disclosureIndicatorImageName = disclosureIndicatorImageName

        let deleteAllChat = PTFunctionCellModel()
        deleteAllChat.name = .deleteAllChat
        deleteAllChat.haveDisclosureIndicator = true
        deleteAllChat.nameColor = .gobalTextColor
        deleteAllChat.disclosureIndicatorImageName = disclosureIndicatorImageName

        chatMain.models = [savedMessage,deleteAllChat]
        
        let apiMain = PTSettingModels()
        apiMain.name = "API"

        //MARK: API
        let aiType = PTFunctionCellModel()
        aiType.name = .apiAIType
        aiType.haveDisclosureIndicator = true
        aiType.nameColor = .gobalTextColor
        aiType.disclosureIndicatorImageName = disclosureIndicatorImageName
        
        let aiToken = PTFunctionCellModel()
        aiToken.name = .apiAIToken
        aiToken.haveDisclosureIndicator = true
        aiToken.nameColor = .gobalTextColor
        aiToken.disclosureIndicatorImageName = disclosureIndicatorImageName

        let getApiToken = PTFunctionCellModel()
        getApiToken.name = .getAPIAIToken
        getApiToken.haveDisclosureIndicator = true
        getApiToken.nameColor = .gobalTextColor
        getApiToken.disclosureIndicatorImageName = disclosureIndicatorImageName

        apiMain.models = [aiType,aiToken,getApiToken]
        
        let otherMain = PTSettingModels()
        otherMain.name = "其他"

        //MARK: Other
        let github = PTFunctionCellModel()
        github.name = .github
        github.haveDisclosureIndicator = true
        github.nameColor = .gobalTextColor
        github.disclosureIndicatorImageName = disclosureIndicatorImageName

        let forum = PTFunctionCellModel()
        forum.name = .forum
        forum.haveDisclosureIndicator = true
        forum.nameColor = .gobalTextColor
        forum.disclosureIndicatorImageName = disclosureIndicatorImageName

        let rate = PTFunctionCellModel()
        rate.name = .rate
        rate.haveDisclosureIndicator = true
        rate.nameColor = .gobalTextColor
        rate.disclosureIndicatorImageName = disclosureIndicatorImageName

        let version = PTFunctionCellModel()
        version.name = .version
        version.haveDisclosureIndicator = false
        version.nameColor = .gobalTextColor
        version.content = "v" + kAppVersion!
        version.contentTextColor = .gobalTextColor
        
        otherMain.models = [github,forum,rate,version]
        return [themeMain,chatMain,apiMain,otherMain]
    }()

    var mSections = [PTSection]()
    func comboLayout()->UICollectionViewCompositionalLayout
    {
        let layout = UICollectionViewCompositionalLayout.init { section, environment in
            self.generateSection(section: section)
        }
        layout.register(PTBaseDecorationView_Corner.self, forDecorationViewOfKind: "background")
        layout.register(PTBaseDecorationView.self, forDecorationViewOfKind: "background_no")
        return layout
    }
    
    func generateSection(section:NSInteger)->NSCollectionLayoutSection
    {
        let sectionModel = mSections[section]

        var group : NSCollectionLayoutGroup
        let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
        
        var bannerGroupSize : NSCollectionLayoutSize
        var customers = [NSCollectionLayoutGroupCustomItem]()
        var groupH:CGFloat = 0
        sectionModel.rows.enumerated().forEach { (index,model) in
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2, height: 44), zIndex: 1000+index)
            customers.append(customItem)
            groupH += 44
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
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

        let headerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.headerHeight ?? CGFloat.leastNormalMagnitude))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topTrailing)
        laySection.boundarySupplementaryItems = [headerItem]

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showDetail()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = "設置"
        self.view.backgroundColor = PTAppBaseConfig.share.viewControllerBaseBackgroundColor
        // Do any additional setup after loading the view.
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
    }
    
    func showDetail()
    {
        mSections.removeAll()

        self.aboutModels.enumerated().forEach { (index,value) in
            var rows = [PTRows]()
            value.models.enumerated().forEach { (subIndex,subValue) in
                let row_List = PTRows.init(title: subValue.name, placeholder: subValue.content,cls: PTFusionCell.self, ID: PTFusionCell.ID, dataModel: subValue)
                rows.append(row_List)
            }
            let cellSection = PTSection.init(headerTitle:value.name,headerCls:PTSettingHeader.self,headerID: PTSettingHeader.ID,headerHeight: 34,rows: rows)
            mSections.append(cellSection)
        }
        
        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }
}

extension PTSettingListViewController:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionHeader
        {
            if itemSec.headerID == PTSettingHeader.ID
            {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.headerID!, for: indexPath) as! PTSettingHeader
                header.titleLabel.text = itemSec.headerTitle
                return header
            }
            return UICollectionReusableView()
        }
        else
        {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTFusionCell.ID
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.cellModel = (itemRow.dataModel as! PTFunctionCellModel)
//            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.lineView.isHidden = false
            cell.dataContent.topLineView.isHidden = false
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.title == .colorString
        {
            let vc = PTColorSettingViewController()
            self.navigationController?.pushViewController(vc)
        }
        else if itemRow.title == .savedChat
        {
            let vc = PTSaveChatViewController()
            self.navigationController?.pushViewController(vc)
        }
        else if itemRow.title == .deleteAllChat
        {
            UIAlertController.base_alertVC(title: "提示",msg: "您想要刪除全部聊天記錄嗎?",okBtns: ["確定"],cancelBtn: "取消") {
                
            } moreBtn: { index, title in
                UserDefaults.standard.set("", forKey: uChatHistory)
                PTBaseViewController.gobal_drop(title: "刪除成功")
            }
        }
    }
}


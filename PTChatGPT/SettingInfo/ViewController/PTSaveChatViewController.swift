//
//  PTSaveChatViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import SwipeCellKit
import LXFProtocolTool

class PTSaveChatViewController: PTChatBaseViewController {

    var saveChatModel = [PTFavouriteModel?]()
    fileprivate var isSwipeRightEnabled = false

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
        sectionModel.rows.enumerated().forEach { (index,model) in
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: PTAppBaseConfig.share.defaultViewSpace, y: groupH, width: CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2, height: CGFloat.ScaleW(w: 44)), zIndex: 1000+index)
            customers.append(customItem)
            groupH += CGFloat.ScaleW(w: 44)
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
        group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
            customers
        })
        
        let sectionInsets = NSDirectionalEdgeInsets.init(top: 10, leading: 0, bottom: 0, trailing: 0)
        let laySection = NSCollectionLayoutSection(group: group)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTLanguage.share.text(forKey: "selected_List")
        self.saveChatModel = AppDelegate.appDelegate()!.appConfig.getSaveChatData()

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshViewAndLoadNewData), name: NSNotification.Name(rawValue: kRefreshControllerAndLoadNewData), object: nil)

        self.view.backgroundColor = .gobalScrollerBackgroundColor
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        
        self.showEmptyDataSet(currentScroller: self.collectionView)
        self.lxf_tapEmptyView(self.collectionView) { sender in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        self.showDetail()
    }
    
    @objc func refreshViewAndLoadNewData() {
        self.saveChatModel.removeAll()
        self.saveChatModel = AppDelegate.appDelegate()!.appConfig.getSaveChatData()
        self.showDetail()
    }

    func showDetail() {
        mSections.removeAll()

        if self.saveChatModel.count > 0 {
            var rows = [PTRows]()
            self.saveChatModel.enumerated().forEach { (index,value) in
                let disclosureIndicatorImageName = UIImage(systemName: "chevron.right")!.withTintColor(.gobalTextColor,renderingMode: .alwaysOriginal)
                let cellModel = PTFusionCellModel()
                cellModel.name = value!.chatContent
                cellModel.accessoryType = .DisclosureIndicator
                cellModel.nameColor = .gobalTextColor
                cellModel.disclosureIndicatorImage = disclosureIndicatorImageName
                let row_List = PTRows.init(cls: PTFusionSwipeCell.self, ID: PTFusionSwipeCell.ID, dataModel: cellModel)
                rows.append(row_List)
            }
            let cellSection = PTSection.init(rows: rows)
            mSections.append(cellSection)
        }

        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }
    
    class open func swipe_cell_buttonStyle(_ type:ButtonStyle? = .circular)->ButtonStyle {
        type!
    }
    
    class open func swipe_cell_buttonDisplayMode(_ type:ButtonDisplayMode? = .imageOnly)->ButtonDisplayMode {
        type!
    }

}

extension PTSaveChatViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionHeader {
            if itemSec.headerID == PTSettingHeader.ID {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.headerID!, for: indexPath) as! PTSettingHeader
                header.titleLabel.text = itemSec.headerTitle
                return header
            }
            return UICollectionReusableView()
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTFusionSwipeCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionSwipeCell
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            cell.dataContent.lineView.isHidden = indexPath.row == (itemSec.rows.count - 1) ? true : false
            cell.dataContent.topLineView.isHidden = true
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PTChatViewController(saveModel: self.saveChatModel[indexPath.row]!.chats)
        self.navigationController?.pushViewController(vc)
    }
}

extension PTSaveChatViewController:SwipeCollectionViewCellDelegate {
    func swipe_cell_configure(action: SwipeAction, with descriptor: ActionDescriptor,buttonDisplayMode: ButtonDisplayMode? = PTSaveChatViewController.swipe_cell_buttonDisplayMode(),buttonStyle: ButtonStyle? = PTSaveChatViewController.swipe_cell_buttonStyle()) {
       action.title = descriptor.title(forDisplayMode: buttonDisplayMode!)
       action.image = descriptor.image(forStyle: buttonStyle!, displayMode: buttonDisplayMode!)
       action.hidesWhenSelected = true
       
       switch buttonStyle! {
       case .backgroundColor:
           action.backgroundColor = descriptor.color(forStyle: buttonStyle!)
       case .circular:
           action.backgroundColor = .clear
           action.textColor = descriptor.color(forStyle: buttonStyle!)
           action.font = UIFont.appfont(size: 13)
           action.transitionDelegate = ScaleTransition.default
       }
   }

   
   func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
       var options = SwipeOptions()
       options.expansionStyle = orientation == .left ? .selection : .destructive(automaticallyDelete: false)
       options.transitionStyle = .border
       switch PTSaveChatViewController.swipe_cell_buttonStyle() {
       case .backgroundColor:
           options.buttonSpacing = 4
       case .circular:
           options.buttonSpacing = 4
           options.backgroundColor = .clear
       }
       return options
   }
   
   func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       if orientation == .right {
           
           let delete = SwipeAction(style: .destructive, title: PTLanguage.share.text(forKey: "cell_Delete")) { action, indexPath in
               PTGCDManager.gcdMain {
                   UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg:PTLanguage.share.text(forKey: "cell_Delete_one_cell"),msgColor: .gobalTextColor,okBtns:[PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                       self.showDetail()
                   } moreBtn: { index, title in
                       self.saveChatModel.remove(at: indexPath.row)
                       self.mSections[0].rows.remove(at: indexPath.row)
                       PTGCDManager.gcdMain {
                           AppDelegate.appDelegate()!.appConfig.favouriteChat = self.saveChatModel.kj.JSONObjectArray()
                       }
                       self.showDetail()
                       PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_done"))
                   }
               }
           }
           delete.font = .appfont(size: 14)
           delete.backgroundColor = .red
           delete.fulfill(with: .delete)
           self.swipe_cell_configure(action: delete, with: .trash)
           return  [delete]
       } else {
           guard isSwipeRightEnabled else { return nil }

           let read = SwipeAction(style: .default, title: nil) { action, indexPath in
           }

           read.hidesWhenSelected = true

           let descriptor: ActionDescriptor = .unread
           self.swipe_cell_configure(action: read, with: descriptor)
           return [read]
       }
   }
}

extension PTSaveChatViewController {
    override func showEmptyDataSet(currentScroller: UIScrollView) {
        self.lxf_EmptyDataSet(currentScroller) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            let color:UIColor = .gobalTextColor
            return [
                .tipStr : PTLanguage.share.text(forKey: "chat_Select"),
                .tipColor : color,
                .verticalOffset : 0,
                .tipImage : UIImage(systemName:"info.circle.fill")!.withTintColor(.gobalTextColor, renderingMode: .automatic)
            ]
        }
    }
    
    override func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        return NSAttributedString()
    }
}

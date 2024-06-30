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
    lazy var collectionView : PTCollectionView = {
        
        let emptyConfig = PTEmptyDataViewConfig()
        emptyConfig.image = UIImage(systemName:"info.circle.fill")!.withTintColor(.gobalTextColor, renderingMode: .automatic)
        emptyConfig.buttonTitle = PTAppConfig.languageFunc(text: "chat_Select")
        emptyConfig.buttonTextColor = .gobalTextColor
        
        let decationViewModel = PTDecorationItemModel()
        decationViewModel.decorationID = PTBaseDecorationView_Corner.ID
        decationViewModel.decorationClass = PTBaseDecorationView_Corner.self
        
        let config = PTCollectionViewConfig()
        config.viewType = .Gird
        config.itemHeight = CGFloat.ScaleW(w: 44)
        config.itemOriginalX = PTAppBaseConfig.share.defaultViewSpace
        config.decorationModel = [decationViewModel]
        config.decorationItemsEdges = NSDirectionalEdgeInsets(top: 10, leading: PTAppBaseConfig.share.defaultViewSpace, bottom: 0, trailing: PTAppBaseConfig.share.defaultViewSpace)
        config.showEmptyAlert = true
        config.emptyViewConfig = emptyConfig
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTFusionSwipeCell.ID:PTFusionSwipeCell.self])
        view.indexPathSwipe = { sectionModel,indexPath in
            return true
        }
        view.swipeLeftHandler = { collectionView,sectionModel,indexPath in
            let delete = SwipeAction(style: .destructive, title: PTAppConfig.languageFunc(text: "cell_Delete")) { action, indexPath in
                PTGCDManager.gcdMain {
                    UIAlertController.base_alertVC(title: PTAppConfig.languageFunc(text: "alert_Info"),titleColor: .gobalTextColor,msg:PTAppConfig.languageFunc(text: "cell_Delete_one_cell"),msgColor: .gobalTextColor,okBtns:[PTAppConfig.languageFunc(text: "button_Confirm")],cancelBtn: PTAppConfig.languageFunc(text: "button_Cancel")) {
                        self.showDetail()
                    } moreBtn: { index, title in
                        self.saveChatModel.remove(at: indexPath.row)
                        self.mSections[0].rows.remove(at: indexPath.row)
                        PTGCDManager.gcdMain {
                            AppDelegate.appDelegate()!.appConfig.favouriteChat = self.saveChatModel.kj.JSONObjectArray()
                        }
                        self.showDetail()
                        PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Delete_done"))
                    }
                }
            }
            delete.font = .appfont(size: 14)
            delete.backgroundColor = .red
            delete.fulfill(with: .delete)
            self.swipe_cell_configure(action: delete, with: .trash)
            return  [delete]
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionSwipeCell
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            return cell
        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
            let vc = PTChatViewController(saveModel: self.saveChatModel[indexPath.row]!.chats)
            self.navigationController?.pushViewController(vc)
        }
        view.emptyTap = { control in
            self.navigationController?.popToRootViewController(animated: true)
        }
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTAppConfig.languageFunc(text: "selected_List")
        self.saveChatModel = AppDelegate.appDelegate()!.appConfig.getSaveChatData()

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshViewAndLoadNewData), name: NSNotification.Name(rawValue: kRefreshControllerAndLoadNewData), object: nil)

        self.view.backgroundColor = .gobalScrollerBackgroundColor
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
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
                let row_List = PTRows.init(ID: PTFusionSwipeCell.ID, dataModel: cellModel)
                rows.append(row_List)
            }
            let cellSection = PTSection.init(rows: rows)
            mSections.append(cellSection)
        }

        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
    
    class open func swipe_cell_buttonStyle(_ type:ButtonStyle? = .circular)->ButtonStyle {
        type!
    }
    
    class open func swipe_cell_buttonDisplayMode(_ type:ButtonDisplayMode? = .imageOnly)->ButtonDisplayMode {
        type!
    }

}

extension PTSaveChatViewController {
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
}

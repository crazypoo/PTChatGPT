//
//  PTSuggesstionViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 28/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import JXPagingView

class PTSuggesstionViewController: PTChatBaseViewController {
    
    private var listViewDidScrollCallback:((_ scrollView:UIScrollView)->Void)?

    var currentIndex:Int = 0
    
    var mSections = [PTSection]()
    lazy var collectionView : PTCollectionView = {
        let config = PTCollectionViewConfig()
        config.viewType = .WaterFall
        config.rowCount = 2
        config.itemOriginalX = PTAppBaseConfig.share.defaultViewSpace
        config.cellLeadingSpace = 15
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTSuggesstionCell.ID:PTSuggesstionCell.self])
        view.waterFallLayout = { index,model in
            let itemRightSapce:CGFloat = 15
            var screenW:CGFloat = 0
            if Gobal_device_info.isPad {
                screenW = (CGFloat.kSCREEN_WIDTH - iPadSplitMainControl)
            } else {
                screenW = CGFloat.kSCREEN_WIDTH
            }

            let cellWidth = (screenW - PTAppBaseConfig.share.defaultViewSpace * 2 - itemRightSapce) / 2
            let cellModel = (model as! PTRows).dataModel as! PTSampleModels
            
            let titleHeight = UIView.sizeFor(string: cellModel.keyName, font: PTSuggesstionCell.titleFont,lineSpacing: 5, height: CGFloat(MAXFLOAT), width: (cellWidth - 20)).height + 10
            
            let nameHeight = UIView.sizeFor(string: cellModel.who.stringIsEmpty() ? "@anonymous" : cellModel.who, font: PTSuggesstionCell.nameFont,lineSpacing: 5, height: CGFloat(MAXFLOAT), width: (cellWidth - 20)).height + 10
            
            let contentHeight = UIView.sizeFor(string: cellModel.systemContent, font: PTSuggesstionCell.infoFont,lineSpacing: 5, height: CGFloat(MAXFLOAT), width: (cellWidth - 20)).height + 10
            
            return titleHeight + nameHeight + contentHeight + 10 + 34 + 10
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTSuggesstionCell
            cell.cellModel = (itemRow.dataModel as! PTSampleModels)
            cell.contentView.backgroundColor = .random
            cell.addButton.addActionHandlers { sender in
                let cellModel = (itemRow.dataModel as! PTSampleModels)
                UIAlertController.base_alertVC(title: PTAppConfig.languageFunc(text: "alert_Info"),titleColor: .gobalTextColor,msg: PTAppConfig.languageFunc(text: "bot_Suggesstion_import_msg"),msgColor: .gobalTextColor,okBtns: [PTAppConfig.languageFunc(text: "button_Confirm")],cancelBtn: PTAppConfig.languageFunc(text: "button_Cancel")) {
                    
                } moreBtn: { index, title in
                    
                    var appSegData = AppDelegate.appDelegate()!.appConfig.tagDataArr()
                    
                    let newTag = PTSegHistoryModel()
                    newTag.keyName = cellModel.keyName
                    newTag.systemContent = cellModel.systemContent
                    appSegData.append(newTag)
                    
                    AppDelegate.appDelegate()?.appConfig.setChatData = appSegData.kj.JSONObjectArray()
                    
                    self.currentModels = AppDelegate.appDelegate()!.appConfig.getJsonFileModel(index: self.currentIndex)
                    self.showDetail()
                    if Gobal_device_info.isPad {
                        let master = self.splitViewController?.viewControllers.first as! PTChatMasterControl
                        master.loadData()
                    }
                }
            }
            return cell
        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
        }
        return view
    }()
    
    var currentModels:[PTSampleModels] = [PTSampleModels]()
    
    init(currentViewModel:[PTSampleModels]) {
        super.init(nibName: nil, bundle: nil)
        self.currentModels = currentViewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.zx_hideBaseNavBar = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.addSubviews([self.collectionView])
        
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
                
        self.showDetail()
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.currentModels.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(ID: PTSuggesstionCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)

        self.collectionView.showCollectionDetail(collectionData: mSections)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}

extension PTSuggesstionViewController:JXPagingViewListViewDelegate {
    func listView() -> UIView {
        return view
    }
    
    func listScrollView() -> UIScrollView {
        return self.collectionView.contentCollectionView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
}

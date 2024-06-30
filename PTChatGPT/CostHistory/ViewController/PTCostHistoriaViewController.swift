//
//  PTCostHistoriaViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 7/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import LXFProtocolTool

class PTCostHistoriaViewController: PTChatBaseViewController {
    
    let costHistoria = AppDelegate.appDelegate()!.appConfig.getCostHistoriaData()
    
    var mSections = [PTSection]()
    lazy var collectionView : PTCollectionView = {
        let emptyConfig = PTEmptyDataViewConfig()
        emptyConfig.image = UIImage(systemName:"info.circle.fill")!.withTintColor(.gobalTextColor, renderingMode: .automatic)
        emptyConfig.buttonTitle = PTAppConfig.languageFunc(text: "cost_Empty")
        emptyConfig.buttonTextColor = .gobalTextColor

        let decorationModel = PTDecorationItemModel()
        decorationModel.decorationID = PTBaseDecorationView_Corner.ID
        decorationModel.decorationClass = PTBaseDecorationView_Corner.self
        
        let config = PTCollectionViewConfig()
        config.viewType = .Custom
        config.decorationModel = [decorationModel]
        config.decorationItemsEdges = NSDirectionalEdgeInsets(top: 0, leading: PTAppBaseConfig.share.defaultViewSpace, bottom: 0, trailing: PTAppBaseConfig.share.defaultViewSpace)
        config.showEmptyAlert = true
        config.emptyViewConfig = emptyConfig
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTCostCell.ID:PTCostCell.self])
        view.customerLayout = { sectionIndex,sectionModel in
            var group : NSCollectionLayoutGroup
            let behavior : UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
            
            var bannerGroupSize : NSCollectionLayoutSize
            var customers = [NSCollectionLayoutGroupCustomItem]()
            var groupH:CGFloat = 0
            var screenW:CGFloat = 0
            if Gobal_device_info.isPad {
                screenW = (CGFloat.kSCREEN_WIDTH - iPadSplitMainControl)
            } else {
                screenW = CGFloat.kSCREEN_WIDTH
            }
            sectionModel.rows.enumerated().forEach { (index,model) in
                let cellHeight:CGFloat = 170
                let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: 10, y: groupH, width: screenW - PTAppBaseConfig.share.defaultViewSpace * 2, height: cellHeight), zIndex: 1000+index)
                customers.append(customItem)
                groupH += cellHeight
            }
            bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(screenW), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
            group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
                customers
            })

            return group
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cellModel = (itemRow.dataModel as! PTCostMainModel)
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTCostCell
            cell.cellModel = cellModel
            cell.lineView.isHidden = indexPath.row == (self.costHistoria.count - 1)
            return cell
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zx_navTitle = PTAppConfig.languageFunc(text: "cost_Title")
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        
        self.showDetail()
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.costHistoria.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(ID: PTCostCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let sections = PTSection.init(rows: rows)
        mSections.append(sections)

        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
}

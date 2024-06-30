//
//  PTPopoverMenuViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 20/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

extension String {
    static let addTag = PTAppConfig.languageFunc(text: "alert_Add_tag")
    static let deleteHistory = PTAppConfig.languageFunc(text: "alert_Delete_current_history")
}

class PTPopoverMenuControl: PTChatBaseViewController {
    
    let popoverWidth:CGFloat = 200
    let popoverCellBaseHeight:CGFloat = 44
    
    var selectActionBlock:((_ selectAction:String)->Void)?
    
    lazy var cellModels:[PTFusionCellModel] = {
        let addTag = PTFusionCellModel()
        addTag.leftImage = UIImage(systemName: "plus.circle")
        addTag.name = .addTag
        addTag.imageTopOffset = 10
        addTag.imageBottomOffset = 10
        addTag.nameColor = .gobalTextColor
        
        let delete = PTFusionCellModel()
        delete.leftImage = UIImage(systemName: "minus.circle.fill")
        delete.name = .deleteHistory
        delete.imageTopOffset = 10
        delete.imageBottomOffset = 10
        delete.nameColor = .gobalTextColor

        return [addTag,delete]
    }()

    var mSections = [PTSection]()
    lazy var collectionView : PTCollectionView = {
        let config = PTCollectionViewConfig()
        config.viewType = .Custom
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTFusionCell.ID:PTFusionCell.self])
        view.customerLayout = { sectionIndex,sectionModel in
            return UICollectionView.girdCollectionLayout(data: sectionModel.rows,groupWidth: self.popoverWidth - 20, itemHeight: self.popoverCellBaseHeight,cellRowCount: 1)
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTFusionCell
            cell.cellModel = (itemRow.dataModel as! PTFusionCellModel)
            return cell
        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cellModel = (itemRow.dataModel as! PTFusionCellModel)
            if self.selectActionBlock != nil {
                self.selectActionBlock!(cellModel.name)
            }
            self.returnFrontVC()
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(15)
        }
        
        self.showDetail()
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.cellModels.enumerated().forEach { (index,value) in
            let row_List = PTRows(ID: PTFusionCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)

        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
}


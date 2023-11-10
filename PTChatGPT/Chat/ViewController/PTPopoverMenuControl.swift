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
    static let addTag = PTLanguage.share.text(forKey: "alert_Add_tag")
    static let deleteHistory = PTLanguage.share.text(forKey: "alert_Delete_current_history")
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
            let cellHeight:CGFloat = self.popoverCellBaseHeight
            let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: 0, y: groupH, width: self.popoverWidth, height: cellHeight), zIndex: 1000+index)
            customers.append(customItem)
            groupH += cellHeight
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(self.popoverWidth - 20), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
        group = NSCollectionLayoutGroup.custom(layoutSize: bannerGroupSize, itemProvider: { layoutEnvironment in
            customers
        })
        
        let sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

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
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(15)
        }
        
        self.showDetail()
    }
    
    func showDetail()
    {
        mSections.removeAll()

        var rows = [PTRows]()
        self.cellModels.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(cls: PTFusionCell.self, ID: PTFusionCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)

        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }
}

extension PTPopoverMenuControl:UICollectionViewDelegate,UICollectionViewDataSource
{
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
//            cell.dataContent.lineView.isHidden = true
//            cell.dataContent.topLineView.isHidden = indexPath.row == 0 ? true : false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        let cellModel = (itemRow.dataModel as! PTFusionCellModel)
        if self.selectActionBlock != nil {
            self.selectActionBlock!(cellModel.name)
        }
        self.returnFrontVC()
    }
}


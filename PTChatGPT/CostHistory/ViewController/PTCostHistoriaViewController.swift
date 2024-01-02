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
        
        let sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets

        let backItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        backItem.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: PTAppBaseConfig.share.defaultViewSpace, bottom: 0, trailing: PTAppBaseConfig.share.defaultViewSpace)
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
        
        self.zx_navTitle = PTAppConfig.languageFunc(text: "cost_Title")
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(CGFloat.kNavBarHeight_Total)
        }
        
        self.showEmptyDataSet(currentScroller: self.collectionView)
        self.showDetail()
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.costHistoria.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(cls: PTCostCell.self, ID: PTCostCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let sections = PTSection.init(rows: rows)
        mSections.append(sections)

        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }

}

extension PTCostHistoriaViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTCostCell.ID {
            let cellModel = (itemRow.dataModel as! PTCostMainModel)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTCostCell
            cell.cellModel = cellModel
            cell.lineView.isHidden = indexPath.row == (self.costHistoria.count - 1)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
}

//MARK: LXFEmptyDataSetable
extension PTCostHistoriaViewController {
    override func showEmptyDataSet(currentScroller: UIScrollView) {
        self.lxf_EmptyDataSet(currentScroller) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            let color:UIColor = .gobalTextColor
            return [
                .tipStr : PTAppConfig.languageFunc(text: "cost_Empty"),
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

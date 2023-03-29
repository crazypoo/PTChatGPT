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
        let itemRightSapce:CGFloat = 15
        let cellWidth = (CGFloat.kSCREEN_WIDTH - PTAppBaseConfig.share.defaultViewSpace * 2 - itemRightSapce) / 2
        let originalX = PTAppBaseConfig.share.defaultViewSpace
        let contentTopAndBottom:CGFloat = 10
        var x:CGFloat = originalX,y:CGFloat = 0 + contentTopAndBottom
        sectionModel.rows.enumerated().forEach { (index,model) in
            let cellModel = model.dataModel as! PTSampleModels
            
            let titleHeight = UIView.sizeFor(string: cellModel.keyName, font: PTSuggesstionCell.titleFont,lineSpacing: 5, height: CGFloat(MAXFLOAT), width: (cellWidth - 20)).height + 10
            
            let nameHeight = UIView.sizeFor(string: cellModel.who.stringIsEmpty() ? "@anonymous" : cellModel.who, font: PTSuggesstionCell.nameFont,lineSpacing: 5, height: CGFloat(MAXFLOAT), width: (cellWidth - 20)).height + 10
            
            let contentHeight = UIView.sizeFor(string: cellModel.systemContent, font: PTSuggesstionCell.infoFont,lineSpacing: 5, height: CGFloat(MAXFLOAT), width: (cellWidth - 20)).height + 10

            let itemH:CGFloat = titleHeight + nameHeight + contentHeight + 10 + 34 + 10
            if index < 2 {
                let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: x, y: y, width: cellWidth, height: itemH), zIndex: 1000+index)
                customers.append(customItem)
                x += cellWidth + itemRightSapce
                if index == (sectionModel.rows.count - 1) {
                    groupH = y + itemH + contentTopAndBottom
                }
            } else {
                x += cellWidth + itemRightSapce
                if index > 0 && (index % 2 == 0) {
                    x = originalX
                    y = (customers[index - 2].frame.height + 10 + customers[index - 2].frame.origin.y)
                } else {
                    y = (customers[index - 2].frame.height + 10 + customers[index - 2].frame.origin.y)
                }

                if index == (sectionModel.rows.count - 1) {
                    let lastHeight = (y + itemH + contentTopAndBottom)
                    let lastLastHeight = (customers[index - 1].frame.height + contentTopAndBottom + customers[index - 1].frame.origin.y)
                    if lastLastHeight > lastHeight {
                        groupH = lastLastHeight
                    } else {
                        groupH = lastHeight
                    }
                }
                let customItem = NSCollectionLayoutGroupCustomItem.init(frame: CGRect.init(x: x, y: y, width: cellWidth, height: itemH), zIndex: 1000+index)
                customers.append(customItem)
            }
        }
        bannerGroupSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(CGFloat.kSCREEN_WIDTH), heightDimension: NSCollectionLayoutDimension.absolute(groupH))
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
            let row_List = PTRows.init(cls: PTSuggesstionCell.self, ID: PTSuggesstionCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)

        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}

extension PTSuggesstionViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTSuggesstionCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTSuggesstionCell
            cell.cellModel = (itemRow.dataModel as! PTSampleModels)
            cell.contentView.backgroundColor = .random
            cell.addButton.addActionHandlers { sender in
                let cellModel = (itemRow.dataModel as! PTSampleModels)
                UIAlertController.base_alertVC(title: PTLanguage.share.text(forKey: "alert_Info"),titleColor: .gobalTextColor,msg: PTLanguage.share.text(forKey: "bot_Suggesstion_import_msg"),msgColor: .gobalTextColor,okBtns: [PTLanguage.share.text(forKey: "button_Confirm")],cancelBtn: PTLanguage.share.text(forKey: "button_Cancel")) {
                    
                } moreBtn: { index, title in
                    
                    var appSegData = AppDelegate.appDelegate()!.appConfig.tagDataArr()
                    
                    let newTag = PTSegHistoryModel()
                    newTag.keyName = cellModel.keyName
                    newTag.systemContent = cellModel.systemContent
                    appSegData.append(newTag)
                    var jsonArr = [String]()
                    appSegData.enumerated().forEach { index,value in
                        jsonArr.append(value.toJSON()!.toJSON()!)
                    }
                    AppDelegate.appDelegate()?.appConfig.segChatHistory = jsonArr.joined(separator: kSeparatorSeg)
                    self.showDetail()
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
}

extension PTSuggesstionViewController:JXPagingViewListViewDelegate {
    func listView() -> UIView {
        return view
    }
    
    func listScrollView() -> UIScrollView {
        return self.collectionView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
}

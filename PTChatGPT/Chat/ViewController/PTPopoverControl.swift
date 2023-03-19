//
//  PTPopoverControl.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 19/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import SwipeCellKit

class PTPopoverControl: PTChatBaseViewController {

    let popoverWidth:CGFloat = CGFloat.kSCREEN_WIDTH - 30
    fileprivate var isSwipeRightEnabled = false

    var currentHistoryModel = PTSegHistoryModel()
    
    var selectedBlock:((_ selectedModel:PTSegHistoryModel)->Void)?
    var refreshTagArr:(()->Void)?

    var segDataArr:[PTSegHistoryModel] = {
        var arr = [PTSegHistoryModel]()
        let dataString = AppDelegate.appDelegate()?.appConfig.segChatHistory
        let dataArr = dataString!.components(separatedBy: kSeparatorSeg)
        dataArr.enumerated().forEach { index,value in
            let model = PTSegHistoryModel.deserialize(from: value)
            arr.append(model!)
        }
        return arr
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
            let cellHeight:CGFloat = 44
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

    init(currentSelect:PTSegHistoryModel) {
        super.init(nibName: nil, bundle: nil)
        self.currentHistoryModel = currentSelect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(15)
        }
        
        self.showDetail()
        
        
        var indexPath = IndexPath()
        self.segDataArr.enumerated().forEach { index,value in
            if value.keyName == self.currentHistoryModel.keyName
            {
                indexPath = IndexPath.init(row: index, section: 0)
            }
        }
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    func showDetail()
    {
        mSections.removeAll()

        var rows = [PTRows]()
        self.segDataArr.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(cls: PTPopoverCell.self, ID: PTPopoverCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)

        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }

}

extension PTPopoverControl:UICollectionViewDelegate,UICollectionViewDataSource
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
        if itemRow.ID == PTPopoverCell.ID
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTPopoverCell
            cell.cellModel = (itemRow.dataModel as! PTSegHistoryModel)
            cell.bottomLine.isHidden = indexPath.row == (self.segDataArr.count - 1) ? true : false
            cell.delegate = self
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
        if self.selectedBlock != nil
        {
            self.selectedBlock!(self.segDataArr[indexPath.row])
        }
        self.returnFrontVC()
    }
}

extension PTPopoverControl:SwipeCollectionViewCellDelegate
{
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
                   if self.segDataArr[indexPath.row].keyName == "Base"
                   {
                       PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_error"))
                       self.showDetail()
                   } else if self.segDataArr[indexPath.row].keyName == self.currentHistoryModel.keyName && self.segDataArr[indexPath.row].keyName != "Base" {
                       self.segDataArr.remove(at: indexPath.row)
                       if self.selectedBlock != nil {
                           self.selectedBlock!(self.segDataArr.first!)
                       }
                       
                       PTAppConfig.refreshTagData(segDataArr: self.segDataArr)

                       self.returnFrontVC()
                   } else {
                       self.segDataArr.remove(at: indexPath.row)
                       PTAppConfig.refreshTagData(segDataArr: self.segDataArr)
                       self.showDetail()
                       if self.refreshTagArr != nil {
                           self.refreshTagArr!()
                       }
                   }
               }
           }
           delete.font = .appfont(size: 14)
           delete.backgroundColor = .red
           delete.fulfill(with: .delete)
           self.swipe_cell_configure(action: delete, with: .trash)
           return  [delete]
       }
       else
       {
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

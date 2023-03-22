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
    let popoverCellBaseHeight:CGFloat = 44
    let footerHeight:CGFloat = 44
    fileprivate var isSwipeRightEnabled = false

    var deleteAllTagBlock:(()->Void)?
    var currentHistoryModel = PTSegHistoryModel()
    
    var selectedBlock:((_ selectedModel:PTSegHistoryModel)->Void)?
    var refreshTagArr:(()->Void)?
    var refreshCurrentTag:((_ updateModel:PTSegHistoryModel)->Void)?

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

        if sectionModel.rows.count > 1 {
            let footerSize = NSCollectionLayoutSize.init(widthDimension: NSCollectionLayoutDimension.absolute(self.popoverWidth - 20), heightDimension: NSCollectionLayoutDimension.absolute(sectionModel.footerHeight ?? CGFloat.leastNormalMagnitude))
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem.init(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing)

            laySection.boundarySupplementaryItems = [footerItem]
        }

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
            if value.keyName == self.currentHistoryModel.keyName {
                indexPath = IndexPath.init(row: index, section: 0)
            }
        }
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.segDataArr.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(cls: PTPopoverCell.self, ID: PTPopoverCell.ID, dataModel: value)
            rows.append(row_List)
        }
        
        var sections:PTSection
        if self.segDataArr.count > 1 {
            sections = PTSection.init(footerCls:PTPopoverFooter.self,footerID: PTPopoverFooter.ID,footerHeight: self.footerHeight,rows: rows)
        } else {
            sections = PTSection.init(rows: rows)
        }
        mSections.append(sections)

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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let itemSec = mSections[indexPath.section]
        if kind == UICollectionView.elementKindSectionFooter {
            if itemSec.footerID == PTPopoverFooter.ID {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTPopoverFooter
                footer.deleteButton.addActionHandlers { sender in
                    if self.deleteAllTagBlock != nil {
                        self.deleteAllTagBlock!()
                    }
                    self.returnFrontVC()
                }
                return footer
            }
            return UICollectionReusableView()
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        if itemRow.ID == PTPopoverCell.ID {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTPopoverCell
            cell.cellModel = (itemRow.dataModel as! PTSegHistoryModel)
            cell.bottomLine.isHidden = indexPath.row == (self.segDataArr.count - 1) ? true : false
            if indexPath.row != 0 {
                cell.delegate = self
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
            cell.backgroundColor = .random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedBlock != nil {
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
                   if self.segDataArr[indexPath.row].keyName == "Base" {
                       PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Delete_error"))
                       self.showDetail()
                   } else if self.segDataArr[indexPath.row].keyName == self.currentHistoryModel.keyName && self.segDataArr[indexPath.row].keyName != "Base" {
                       self.segDataArr.remove(at: indexPath.row)
                       if self.selectedBlock != nil {
                           self.selectedBlock!(self.segDataArr.first!)
                       }
                       PTAppConfig.refreshTagData(segDataArr: self.segDataArr)
                       self.preferredContentSize = CGSize(width: self.popoverWidth, height: CGFloat(self.segDataArr.count) * self.popoverCellBaseHeight + (self.segDataArr.count > 1 ? self.footerHeight : 0))
                       self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
                   } else {
                       self.segDataArr.remove(at: indexPath.row)
                       PTAppConfig.refreshTagData(segDataArr: self.segDataArr)
                       self.showDetail()
                       self.preferredContentSize = CGSize(width: self.popoverWidth, height: CGFloat(self.segDataArr.count) * self.popoverCellBaseHeight + (self.segDataArr.count > 1 ? self.footerHeight : 0))

                       for (index,value) in self.segDataArr.enumerated() {
                           if value.keyName == self.currentHistoryModel.keyName {
                               self.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
                               break
                           }
                       }
                       
                       if self.refreshTagArr != nil {
                           self.refreshTagArr!()
                       }
                   }
               }
           }
           delete.font = .appfont(size: 14)
           delete.backgroundColor = .clear
           delete.fulfill(with: .delete)
           self.swipe_cell_configure(action: delete, with: .trash)
           
           let edit = SwipeAction(style: .destructive, title: "编辑") { action, indexPath in
               PTGCDManager.gcdAfter(time: 0.5) {
                   let itemSec = self.mSections[indexPath.section]
                   let itemRow = itemSec.rows[indexPath.row]
                   let cellModel = (itemRow.dataModel as! PTSegHistoryModel)
                   if cellModel.keyName == "Base" {
                       PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Edit_error"))
                   } else {
                       let textKey = PTLanguage.share.text(forKey: "alert_Tag_set")
                       let aiKey = PTLanguage.share.text(forKey: "alert_AI_Set")
                                          
                       let currentTitle = cellModel.keyName
                       let aiSet = cellModel.systemContent

                       UIAlertController.base_textfiele_alertVC(title:PTLanguage.share.text(forKey: "alert_Edit_ai"),titleColor: .gobalTextColor,okBtn: PTLanguage.share.text(forKey: "button_Confirm"), cancelBtn: PTLanguage.share.text(forKey: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey,aiKey], textFieldTexts: [currentTitle,aiSet], keyboardType: [.default,.default],textFieldDelegate: self) { result in
                           let newKey:String? = result[textKey]!
                           let newAiKey:String? = result[aiKey]
                           if !(newKey ?? "").stringIsEmpty() {
                               var segDatas = AppDelegate.appDelegate()?.appConfig.tagDataArr()
                               let currentCellBaseData = segDatas![indexPath.row]
                               currentCellBaseData.keyName = newKey!
                               currentCellBaseData.systemContent = newAiKey ?? ""
                               segDatas![indexPath.row] = currentCellBaseData
                               
                               var jsonArr = [String]()
                               segDatas!.enumerated().forEach { index,value in
                                   jsonArr.append(value.toJSON()!.toJSON()!)
                               }
                               AppDelegate.appDelegate()?.appConfig.segChatHistory = jsonArr.joined(separator: kSeparatorSeg)
                               
                               var indexPathSelect = IndexPath()
                               self.segDataArr.enumerated().forEach { index,value in
                                   if value.keyName == self.currentHistoryModel.keyName {
                                       indexPathSelect = IndexPath.init(row: index, section: 0)
                                   }
                               }
                               self.segDataArr[indexPath.row] = currentCellBaseData
                               self.showDetail()
                               self.collectionView.selectItem(at: indexPathSelect, animated: false, scrollPosition: .top)
                               
                               if indexPathSelect.row == indexPath.row {
                                   if self.refreshCurrentTag != nil {
                                       self.refreshCurrentTag!(currentCellBaseData)
                                   }
                               }
                           } else {
                               PTBaseViewController.gobal_drop(title: PTLanguage.share.text(forKey: "alert_Input_error"))
                           }
                       }

                   }
               }
           }
           edit.font = .appfont(size: 14)
           edit.backgroundColor = .clear
           edit.fulfill(with: .reset)
           self.swipe_cell_configure(action: edit, with: .edit)

           return [delete,edit]
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

extension PTPopoverControl : UITextFieldDelegate {}

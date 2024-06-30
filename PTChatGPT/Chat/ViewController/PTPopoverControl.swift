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
    let popoverCellBaseHeight:CGFloat = 64
    let footerHeight:CGFloat = 44
    fileprivate var isSwipeRightEnabled = false

    var deleteAllTagBlock:(()->Void)?
    var currentHistoryModel = PTSegHistoryModel()
    
    var selectedBlock:((_ selectedModel:PTSegHistoryModel)->Void)?
    var refreshTagArr:(()->Void)?
    var refreshCurrentTag:((_ updateModel:PTSegHistoryModel)->Void)?

    var segDataArr:[PTSegHistoryModel?] = {
        return AppDelegate.appDelegate()!.appConfig.tagDataArr()
    }()

    lazy var collectionView : PTCollectionView = {
        let config = PTCollectionViewConfig()
        config.viewType = .Custom
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTPopoverCell.ID:PTPopoverCell.self])
        view.registerSupplementaryView(classs: [PTPopoverFooter.ID:PTPopoverFooter.self], kind: UICollectionView.elementKindSectionFooter)
        view.customerLayout = { index,section in
            return UICollectionView.girdCollectionLayout(data: section.rows,groupWidth: self.popoverWidth - 30, itemHeight: self.popoverCellBaseHeight,cellRowCount: 1,originalX: 10)
        }
        view.footerInCollection = { kind,collectionView,itemSec,indexPath in
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: itemSec.footerID!, for: indexPath) as! PTPopoverFooter
            footer.deleteButton.addActionHandlers { sender in
                UIAlertController.base_alertVC(title: PTAppConfig.languageFunc(text: "alert_Info"),titleColor: .gobalTextColor,msg: PTAppConfig.languageFunc(text: "alert_delete_all_tag"),msgColor: .gobalTextColor,okBtns: [PTAppConfig.languageFunc(text: "button_Confirm")],cancelBtn: PTAppConfig.languageFunc(text: "button_Cancel")) {
                } moreBtn: { index, title in
                    if self.deleteAllTagBlock != nil {
                        self.deleteAllTagBlock!()
                    }
                    self.returnFrontVC()
                }
            }
            return footer
        }
        view.indexPathSwipe = { model,indexPath in
            if indexPath.row != 0 {
                return true
            }
            return false
        }
        view.swipeLeftHandler = { collection,sectionModel,indexPath in
            let delete = SwipeAction(style: .destructive, title: PTAppConfig.languageFunc(text: "cell_Delete")) { action, indexPath in
                PTGCDManager.gcdMain {
                    if self.segDataArr[indexPath.row]!.keyName == "Base" {
                        PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Delete_error"))
                        self.showDetail()
                    } else if self.segDataArr[indexPath.row]!.keyName == self.currentHistoryModel.keyName && self.segDataArr[indexPath.row]!.keyName != "Base" {
                        self.segDataArr.remove(at: indexPath.row)
                        if self.selectedBlock != nil {
                            self.selectedBlock!(self.segDataArr.first!!)
                        }
                        PTAppConfig.refreshTagData(segDataArr: self.segDataArr)
                        self.preferredContentSize = CGSize(width: self.popoverWidth, height: CGFloat(self.segDataArr.count) * self.popoverCellBaseHeight + (self.segDataArr.count > 1 ? self.footerHeight : 0))
                        self.collectionView.contentCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
                    } else {
                        self.segDataArr.remove(at: indexPath.row)
                        PTAppConfig.refreshTagData(segDataArr: self.segDataArr)
                        self.showDetail()
                        self.preferredContentSize = CGSize(width: self.popoverWidth, height: CGFloat(self.segDataArr.count) * self.popoverCellBaseHeight + (self.segDataArr.count > 1 ? self.footerHeight : 0))

                        for (index,value) in self.segDataArr.enumerated() {
                            if value!.keyName == self.currentHistoryModel.keyName {
                                self.collectionView.contentCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
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
                        PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Edit_error"))
                    } else {
                        let textKey = PTAppConfig.languageFunc(text: "alert_Tag_set")
                        let aiKey = PTAppConfig.languageFunc(text: "alert_AI_Set")
                                           
                        let currentTitle = cellModel.keyName
                        let aiSet = cellModel.systemContent

                        UIAlertController.base_textfield_alertVC(title:PTAppConfig.languageFunc(text: "alert_Edit_ai"),titleColor: .gobalTextColor,okBtn: PTAppConfig.languageFunc(text: "button_Confirm"), cancelBtn: PTAppConfig.languageFunc(text: "button_Cancel"),cancelBtnColor: .systemBlue, placeHolders: [textKey,aiKey], textFieldTexts: [currentTitle,aiSet], keyboardType: [.default,.default],textFieldDelegate: self) { result in
                            let newKey:String? = result[textKey]!
                            let newAiKey:String? = result[aiKey]
                            if !(newKey ?? "").stringIsEmpty() {
                                var segDatas = AppDelegate.appDelegate()?.appConfig.tagDataArr()
                                let currentCellBaseData = segDatas![indexPath.row]
                                currentCellBaseData!.keyName = newKey!
                                currentCellBaseData!.systemContent = newAiKey ?? ""
                                segDatas![indexPath.row] = currentCellBaseData
                                
                                AppDelegate.appDelegate()?.appConfig.setChatData = segDatas!.kj.JSONObjectArray()
                                
                                var indexPathSelect = IndexPath()
                                self.segDataArr.enumerated().forEach { index,value in
                                    if value!.keyName == self.currentHistoryModel.keyName {
                                        indexPathSelect = IndexPath.init(row: index, section: 0)
                                    }
                                }
                                self.segDataArr[indexPath.row] = currentCellBaseData!
                                self.showDetail()
                                self.collectionView.contentCollectionView.selectItem(at: indexPathSelect, animated: false, scrollPosition: .top)
                                
                                if indexPathSelect.row == indexPath.row {
                                    if self.refreshCurrentTag != nil {
                                        self.refreshCurrentTag!(currentCellBaseData!)
                                    }
                                }
                            } else {
                                PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Input_error"))
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
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTPopoverCell
            cell.cellModel = (itemRow.dataModel as! PTSegHistoryModel)
            cell.bottomLine.isHidden = indexPath.row == (self.segDataArr.count - 1) ? true : false
            return cell
        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
            if self.selectedBlock != nil {
                self.selectedBlock!(self.segDataArr[indexPath.row]!)
            }
            self.returnFrontVC()
        }
        return view
    }()
    
    var mSections = [PTSection]()

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
            if value!.keyName == self.currentHistoryModel.keyName {
                indexPath = IndexPath.init(row: index, section: 0)
            }
        }
        self.collectionView.mtSelectItem(indexPath: indexPath, animated: false, scrollPosition: .top)
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.segDataArr.enumerated().forEach { (index,value) in
            let row_List = PTRows(ID: PTPopoverCell.ID, dataModel: value)
            rows.append(row_List)
        }
        
        var sections:PTSection
        if self.segDataArr.count > 1 {
            sections = PTSection(footerID: PTPopoverFooter.ID,footerHeight: self.footerHeight,rows: rows)
        } else {
            sections = PTSection(rows: rows)
        }
        mSections.append(sections)

        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
}

extension PTPopoverControl {
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

extension PTPopoverControl : UITextFieldDelegate {}

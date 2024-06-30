//
//  PTLocalFileViewController.swift
//  ChangePhoneData
//
//  Created by 邓杰豪 on 14/3/23.
//  Copyright © 2023 Jax. All rights reserved.
//

import UIKit
import PooTools
import QuickLook
import LXFProtocolTool

let nRefreshSetting = "nRefreshSetting"

class PTLocalFileViewController: PTChatBaseViewController {

    var localModelArr = [PTLocalFileModel]()
        
    var mSections = [PTSection]()
    
    lazy var collectionView : PTCollectionView = {
        
        let emptyConfig = PTEmptyDataViewConfig()
        emptyConfig.image = "📂".emojiToImage(emojiFont: .appfont(size: 88))
        emptyConfig.buttonTitle = PTAppConfig.languageFunc(text: "local_Empty")
        emptyConfig.buttonTextColor = .black

        let config = PTCollectionViewConfig()
        config.viewType = .Custom
        config.topRefresh = true
        config.showEmptyAlert = true
        config.emptyViewConfig = emptyConfig
        
        let view = PTCollectionView(viewConfig: config)
        view.registerClassCells(classs: [PTLocalFileCell.ID:PTLocalFileCell.self])
        view.customerLayout = { sectionIndex,sectionModel in
            var screenW:CGFloat = 0
            if Gobal_device_info.isPad {
                screenW = (CGFloat.kSCREEN_WIDTH - iPadSplitMainControl)
            } else {
                screenW = CGFloat.kSCREEN_WIDTH
            }

            let cellSize = (screenW - 40) / 3

            return UICollectionView.girdCollectionLayout(data: sectionModel.rows,groupWidth: screenW, itemHeight: cellSize,cellRowCount: 3,originalX: 10,topContentSpace: 10,bottomContentSpace: 10,cellLeadingSpace: 10,cellTrailingSpace: 10)
        }
        view.cellInCollection = { collection,sectionModel,indexPath in
            let itemRow = sectionModel.rows[indexPath.row]
            let cellModel = (itemRow.dataModel as! PTLocalFileModel)
            let cell = collection.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTLocalFileCell
            cell.cellModel = cellModel
            cell.cellAction = self.deleteButton.isSelected
            cell.deleteButton.addActionHandlers { sender in
                let removeAction = FileManager.pt.removefolder(folderPath: (uploadFilePath.appendingPathComponent(cellModel.fileName)))
                if removeAction.isSuccess {
                    self.localModelArr.remove(at: indexPath.row)
                    let baseModel = AppDelegate.appDelegate()!.appConfig.getDownloadInfomation()
                    baseModel.enumerated().forEach { index,value in
                        if value!.folderName == cellModel.fileName {
                            baseModel[index]?.loadFinish = false
                            AppDelegate.appDelegate()!.appConfig.downloadInfomation = baseModel.kj.JSONObjectArray()
                        }
                    }
                    
                    PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Delete_done"))
                    self.showDetail()
                    NotificationCenter.default.post(name: NSNotification.Name(nRefreshSetting), object: nil)
                } else {
                    PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "alert_Delete_error"))
                }
            }
            return cell
        }
        view.collectionDidSelect = { collection,sectionModel,indexPath in
        }
        view.headerRefreshTask = { control in
            self.loadMoreFile()
        }
        return view
    }()
    
    lazy var deleteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        view.setImage(UIImage(systemName: "trash.slash.fill"), for: .selected)
        view.isSelected = false
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            self.showDetail()
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zx_navTitle = PTAppConfig.languageFunc(text: "local_File_title")
        // Do any additional setup after loading the view.
        self.zx_navBar?.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.right.equalToSuperview().inset(PTAppBaseConfig.share.defaultViewSpace)
            make.bottom.equalToSuperview().inset(5)
        }
        self.deleteButton.isHidden = true
        
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.zx_navBar!.snp.bottom)
        }
        
        self.getUploadFileFile()
    }
    
    @objc func loadMoreFile() {
        DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + 1) {
            PTGCDManager.gcdMain {
                self.localModelArr.removeAll()
                self.getUploadFileFile()
            }
        }
    }

    func getUploadFileFile() {
        let arr = FileManager.pt.shallowSearchAllFiles(folderPath: uploadFilePath)
        arr?.enumerated().forEach({ index,value in
            let localModel = PTLocalFileModel()
            localModel.image = "📁".emojiToImage(emojiFont: .appfont(size: 44))
            localModel.fileName = value.lastPathComponent
            self.localModelArr.append(localModel)
        })
        
        self.showDetail()
        if self.localModelArr.count > 0 {
            self.deleteButton.isHidden = false
            self.deleteButton.isUserInteractionEnabled = true
        } else {
            self.deleteButton.isHidden = true
            self.deleteButton.isUserInteractionEnabled = false
        }
    }
    
    func showDetail() {
        mSections.removeAll()

        var rows = [PTRows]()
        self.localModelArr.enumerated().forEach { (index,value) in
            let row_List = PTRows.init(ID: PTLocalFileCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)
        
        self.collectionView.showCollectionDetail(collectionData: mSections)
    }
}
    

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
                
        var screenW:CGFloat = 0
        if Gobal_device_info.isPad {
            screenW = (CGFloat.kSCREEN_WIDTH - iPadSplitMainControl)
        } else {
            screenW = CGFloat.kSCREEN_WIDTH
        }

        let cellSize = (screenW - 40) / 3
        
        group = UICollectionView.girdCollectionLayout(data: sectionModel.rows, itemHeight: cellSize,cellRowCount: 3,originalX: 10,contentTopAndBottom: 10,cellLeadingSpace: 10,cellTrailingSpace: 10)
        
        let sectionInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let laySection = NSCollectionLayoutSection(group: group)
        laySection.orthogonalScrollingBehavior = behavior
        laySection.contentInsets = sectionInsets
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

    private(set) lazy var refreshControl:UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreFile), for: .valueChanged)
        return control
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
        
        self.collectionView.refreshControl = self.refreshControl
        self.view.addSubviews([self.collectionView])
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.zx_navBar!.snp.bottom)
        }
        
        self.showEmptyDataSet(currentScroller: self.collectionView)

        self.getUploadFileFile()
    }
    
    @objc func loadMoreFile() {
        DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + 1) {
            PTGCDManager.gcdMain {
                self.localModelArr.removeAll()
                self.getUploadFileFile()
                self.refreshControl.endRefreshing()
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
            let row_List = PTRows.init(cls: PTLocalFileCell.self, ID: PTLocalFileCell.ID, dataModel: value)
            rows.append(row_List)
        }
        let cellSection = PTSection.init(rows: rows)
        mSections.append(cellSection)
        
        self.collectionView.pt_register(by: mSections)
        self.collectionView.reloadData()
    }
}

extension PTLocalFileViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.mSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mSections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemSec = mSections[indexPath.section]
        let itemRow = itemSec.rows[indexPath.row]
        let cellModel = (itemRow.dataModel as! PTLocalFileModel)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemRow.ID, for: indexPath) as! PTLocalFileCell
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
}
    
extension PTLocalFileViewController {
    override func showEmptyDataSet(currentScroller: UIScrollView) {
        self.lxf_EmptyDataSet(currentScroller) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            let color:UIColor = .black
            return [
                .tipStr : PTAppConfig.languageFunc(text: "local_Empty"),
                .tipColor : color,
                .verticalOffset : 0,
                .tipImage : "📂".emojiToImage(emojiFont: .appfont(size: 88))
            ]
        }
    }
    
    override func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        return NSAttributedString()
    }
}


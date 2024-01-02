//
//  PTStableDiffusionModelCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import Alamofire
import SSZipArchive

class PTStableDiffusionModelCell: PTBaseNormalCell {
    static let ID = "PTStableDiffusionModelCell"
    
    var downloadFinishBlock:(()->Void)?

    var cellModel:PTDownloadModelModel? {
        didSet {
            self.fileUrl = self.cellModel!.url
            self.nameLabel.font = .appfont(size: 16,bold: true)
            self.nameLabel.text = self.cellModel!.name
            self.downLoadStatus.isSelected = self.cellModel!.loadFinish
            self.downLoadStatus.isEnabled = !self.cellModel!.loadFinish
        }
    }
    
    private var fileUrl:String = ""
    
    lazy var nameLabel : UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.textColor = .gobalTextColor
        return view
    }()
    
    lazy var lineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#E8E8E8")
        return view
    }()
    
    lazy var progressInfoLabel:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .appfont(size: 14)
        view.textColor = .gobalTextColor
        return view
    }()
    
    var downLoad = Network.share
    
    lazy var downLoadStatus:UIButton = {
        let view = UIButton(type: .custom)
        view.setImage("▶️".emojiToImage(emojiFont: .appfont(size: 20)), for: [.normal])
        view.setImage("✅".emojiToImage(emojiFont: .appfont(size: 20)), for: [.selected,.disabled])
        view.setImage("❌".emojiToImage(emojiFont: .appfont(size: 20)), for: .selected)
        view.addActionHandlers { sender in
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.progressView.isHidden = false
                self.progressInfoLabel.isHidden = false
                
                PTGCDManager.gcdMain {
                    PTBaseViewController.gobal_drop(title: PTAppConfig.languageFunc(text: "download_Start"))
                }
                
                let tempFile = FileManager.pt.TmpDirectory().appendingPathComponent("\(self.cellModel!.folderName).zip")
                
                if FileManager.pt.judgeFileOrFolderExists(filePath: tempFile) {
                    PTGCDManager.gcdAfter(time: 0.5) {
                        self.progressInfoLabel.text = PTAppConfig.languageFunc(text: "download_Unzip")
                        self.unzipFunction(tempFileUrl: tempFile)
                    }
                } else {
                    Task.init {
                        do {
                            let data = try await Network.fileDownLoad(fileUrl: self.cellModel!.url, saveFilePath: userChatCostFilePath) { bytesRead, totalBytesRead, progress in
                                PTGCDManager.gcdMain {
                                    self.progressView.progress = Float(progress)
                                    self.progressInfoLabel.text = "\(bytesRead) / \(totalBytesRead)"
                                }
                            }
                            try data.write(to: URL(fileURLWithPath: tempFile),options: .atomic)
                            PTNSLogConsole("文件写入成功")
                            PTGCDManager.gcdAfter(time: 0.5) {
                                self.progressInfoLabel.text = PTAppConfig.languageFunc(text: "download_Unzip")
                                self.unzipFunction(tempFileUrl: tempFile)
                            }

                        } catch {
                            sender.isSelected = false
                            PTNSLogConsole("下载失败\(error.localizedDescription)")
                        }
                    }
                }
            } else {
                self.downLoad.cancelDownload()
            }
        }
        return view
    }()
    
    lazy var progressView : UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .orange
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubviews([self.nameLabel,self.lineView,self.downLoadStatus,self.progressView,self.progressInfoLabel])
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(64)
        }
        
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        self.lineView.isHidden = true
        
        self.downLoadStatus.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }
        
        self.progressView.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel.snp.right).offset(10)
            make.right.equalTo(self.downLoadStatus.snp.left).offset(-10)
            make.bottom.equalToSuperview().inset(5)
            make.height.equalTo(10)
        }
        self.progressView.isHidden = true
        
        self.progressInfoLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.progressView)
            make.bottom.equalTo(self.progressView.snp.top).offset(-5)
            make.top.greaterThanOrEqualToSuperview()
        }
        self.progressInfoLabel.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func unzipFunction(tempFileUrl:String) {
        PTGCDManager.gcdAfter(time: 1) {
            PTGCDManager.gcdBackground {
                PTGCDManager.gcdMain {
                    SSZipArchive.unzipFile(atPath: tempFileUrl, toDestination: uploadFilePath, overwrite: true, password: nil) { entry, zipInfo, entryNumber, total in
                        PTGCDManager.gcdMain {
                            PTNSLogConsole("\(entryNumber)\\\\\(total)")
                            self.progressView.progress = Float(entryNumber/total)
                            self.progressInfoLabel.text = "🗃️:\(entryNumber) / \(total)"
                        }
                    } completionHandler: { entry, finish, error in
                        if error != nil {
                            self.downLoadStatus.isSelected = false
                            PTNSLogConsole("unzip error")
                        } else {
                            if finish {
                                PTNSLogConsole("unzip finish")
                                self.progressInfoLabel.text = "OK......"
                                FileManager.pt.removefile(filePath: tempFileUrl)
                                PTGCDManager.gcdAfter(time: 0.5) {
                                    self.progressView.isHidden = true
                                    self.progressInfoLabel.text = ""
                                    self.progressInfoLabel.isHidden = true
                                    self.downLoadStatus.isEnabled = false
                                }
                                if self.downloadFinishBlock != nil {
                                    self.downloadFinishBlock!()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

//
//  PTSuggestionControl.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 29/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import JXSegmentedView
import JXPagingView

extension JXPagingListContainerView: JXSegmentedViewListContainer {}

let JXheightForHeaderInSection: Int = 44

class PTSuggestionControl: PTChatBaseViewController {

    lazy var segTitles = AppDelegate.appDelegate()!.appConfig.getJsonFileTags()
    
    var pagerView: JXPagingView?
    lazy var segmentView:JXSegmentedView = {
        let segmentedView : JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: CGFloat.kSCREEN_WIDTH, height: CGFloat(JXheightForHeaderInSection)))
        segmentedView.backgroundColor = .white
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = true

        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorColor = .orange
        lineView.indicatorWidth = 20
        lineView.indicatorHeight = 5
        segmentedView.indicators = [lineView]
        segmentedView.delegate = self
        return segmentedView
    }()
    
    lazy var customSegDataSource : JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titleSelectedColor = UIColor.black
        dataSource.titleNormalColor = UIColor.lightGray
        dataSource.titleNormalFont = .appfont(size: 15)
        dataSource.titleSelectedFont = .appfont(size: 15)
        dataSource.isTitleColorGradientEnabled = true
        dataSource.isTitleZoomEnabled = true
        dataSource.isSelectedAnimable = true
        dataSource.isItemSpacingAverageEnabled = true
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zx_navTitle = PTLanguage.share.text(forKey: "bot_Suggesstion")

        self.customSegDataSource.titleSelectedColor = .gobalTextColor
        self.customSegDataSource.isItemSpacingAverageEnabled = true
        self.segmentView.backgroundColor = .clear
        createSegData()

        self.pagerView = JXPagingView.init(delegate: self)
        self.pagerView!.mainTableView.gestureDelegate = self
        self.pagerView!.backgroundColor = .clear
        self.pagerView?.mainTableView.backgroundColor = .clear
        self.pagerView?.listContainerView.backgroundColor = .clear
        self.pagerView?.listContainerView.scrollView.isScrollEnabled = false
        view.addSubview(self.pagerView!)
        self.pagerView!.snp.makeConstraints { (make) in
            make.top.equalTo(CGFloat.kNavBarHeight_Total)
            make.bottom.left.right.equalToSuperview()
        }

        if #available(iOS 15.0, *) {
            self.pagerView!.mainTableView.sectionHeaderTopPadding = 0
        }
        
        self.segmentView.listContainer = self.pagerView!.listContainerView
    }
    
    func createSegData() {
        self.customSegDataSource.dataSource.removeAll()
        customSegDataSource.titles = self.segTitles
        self.segmentView.dataSource = self.customSegDataSource
        self.segmentView.backgroundColor = .gobalBackgroundColor
        self.segmentView.reloadData()
    }
}

// MARK: - JXPagingViewDelegate 代理
extension PTSuggestionControl: JXPagingViewDelegate {
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return 0
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return UIView()
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return JXheightForHeaderInSection
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return customSegDataSource.dataSource.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        
        let models = AppDelegate.appDelegate()!.appConfig.getJsonFileModel(index: index)
        let vc = PTSuggesstionViewController(currentViewModel: models)
        vc.currentIndex = index
        return vc
    }
        
    func mainTableViewDidScroll(_ scrollView: UIScrollView) {
    }
}

extension PTSuggestionControl:JXSegmentedViewDelegate
{
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
    }
}

// MARK: - JXPagingMainTableViewGestureDelegate 代理
extension PTSuggestionControl: JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
    }
}

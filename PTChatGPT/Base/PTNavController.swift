//
//  PTNavController.swift
//  PTNetworkTesting
//
//  Created by 邓杰豪 on 6/3/23.
//

import UIKit
import ZXNavigationBar
import PooTools

class PTNavController: ZXNavigationBarNavigationController {

    override var prefersStatusBarHidden: Bool {
        StatusBarManager.shared.isHidden
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        StatusBarManager.shared.style
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        StatusBarManager.shared.animation
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        clearSubStatusBars(isUpdate: false)
        pushStatusBars(for: viewControllers)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
    
    /// 修改导航栏返回按钮
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
 
        if viewControllers.count > 0 {
            let backBtn = UIButton.init(type: .custom)
            backBtn.setImage(UIImage(systemName: "chevron.left")!.withTintColor(.gobalTextColor, renderingMode: .automatic), for: .normal)
            backBtn.bounds = CGRect.init(x: 0, y: 0, width: 34, height: 34)
            backBtn.addActionHandlers { seder in
                self.back()
            }
            let leftItem = UIBarButtonItem.init(customView: backBtn)
            viewController.navigationItem.leftBarButtonItem = leftItem
            viewController.hidesBottomBarWhenPushed = true
        }
        topViewController?.addSubStatusBar(for: viewController)
        super.pushViewController(viewController, animated: animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        // iOS13 默认 UIModalPresentationAutomatic 模式，所以要判断处理一下
        if #available(iOS 13.0, *) {
            // 当 modalPresentationStyle == .automatic , 才需要处理.
            // 如果不加这个判断,可能会导致 present 出来是一个黑色背景的界面. 比如, 做背景半透明的弹窗的时候.
            if viewControllerToPresent.modalPresentationStyle == .automatic {
                viewControllerToPresent.modalPresentationStyle = .fullScreen
            }
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    @objc func back() {
        self.popViewController(animated: true)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        /**
         自定义UINavigationController，需要重写childForStatusBarStyle。
         否则preferredStatusBarStyle不执行。
         */
        topViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.zx_disableFullScreenGesture = false
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = true
        pushStatusBars(for: viewControllers)
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
        
        view.backgroundColor = .gobalBackgroundColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *)
        {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
            {
                StatusBarManager.shared.style = UITraitCollection.current.userInterfaceStyle == .dark ? .lightContent : .darkContent
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}

// MARK: - 左滑手势返回
extension PTNavController: UIGestureRecognizerDelegate,UINavigationControllerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count == 1 {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /******处理右滑手势与scrollview手势冲突*******/
        gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
}

//
//  HSNavControl.swift
//  HornSetting
//
//  Created by 邓杰豪 on 16/12/22.
//  Copyright © 2022 PT. All rights reserved.
//

import UIKit
import PooTools

class HSNavControl: NSObject {
    open class func GobalNavControl(nav:UINavigationController,textColor:UIColor? = .black,navColor:UIColor? = .white)
    {
        let colors:UIColor? = navColor
        let textColors:UIColor? = textColor
        
        //修改导航栏文字颜色字号
        let attrs = [NSAttributedString.Key.foregroundColor: textColors, NSAttributedString.Key.font: UIFont.appfont(size: 24,bold: true)]

        let images = UIColor.clear.createImageWithColor()
        if #available(iOS 15.0, *)
        {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = colors
            navigationBarAppearance.titleTextAttributes = attrs as [NSAttributedString.Key : Any]
            navigationBarAppearance.shadowImage = images
            navigationBarAppearance.backgroundImage = colors!.createImageWithColor()
            navigationBarAppearance.setBackIndicatorImage(colors!.createImageWithColor(), transitionMaskImage: colors!.createImageWithColor())
            nav.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            nav.navigationBar.standardAppearance = navigationBarAppearance
            nav.navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
            nav.navigationBar.setBackgroundImage(colors!.createImageWithColor(), for: .compact)
            
            let toolBarAppearance = UIToolbarAppearance()
            toolBarAppearance.backgroundColor = colors
            nav.toolbar.setBackgroundImage(colors!.createImageWithColor(), forToolbarPosition: .any, barMetrics: .compact)
            nav.toolbar.scrollEdgeAppearance = toolBarAppearance
            nav.toolbar.standardAppearance = toolBarAppearance
            nav.toolbar.compactScrollEdgeAppearance = toolBarAppearance
        }
        else
        {
            /// 去掉导航栏底部黑线。需要同时设置shadowImage 和 setBackgroundImage
            nav.navigationBar.shadowImage = images

            /// 导航栏背景图片
            nav.navigationController?.navigationBar.backgroundColor = colors
            nav.navigationController?.navigationBar.setBackgroundImage(colors!.createImageWithColor(), for: .default)

            nav.navigationBar.apply(gradient: [colors!])
            
            /// 修改UINavigationBar上各个item的文字、图形的颜色
            nav.navigationBar.tintColor = textColors
            
            nav.navigationBar.titleTextAttributes = attrs as [NSAttributedString.Key : Any]
        }
    }

}

//
//  SwipeCellOption.swift
//  咪呐
//
//  Created by 九州所想 on 2022/3/24.
//  Copyright © 2022 MN. All rights reserved.
//

import UIKit

class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}

enum ActionDescriptor {
    case read, unread, more, flag, trash, edit
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return "Read"
        case .unread: return "Unread"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Trash"
        case .edit: return "Edit"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "Read"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "Trash"
        case .edit: name = "Edit"
        }
        
    #if canImport(Combine)
        if #available(iOS 13.0, *) {
            let name: String
            switch self {
            case .read: name = "envelope.open.fill"
            case .unread: name = "envelope.badge.fill"
            case .more: name = "ellipsis.circle.fill"
            case .flag: name = "flag.fill"
            case .trash: name = "trash.fill"
            case .edit: name =  "pencil"

            }

            if style == .backgroundColor {
                let config = UIImage.SymbolConfiguration(pointSize: 23.0, weight: .regular)
                return UIImage(systemName: name, withConfiguration: config)
            } else {
                let config = UIImage.SymbolConfiguration(pointSize: 22.0, weight: .regular)
                let image = UIImage(systemName: name, withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysTemplate)
                return circularIcon(with: color(forStyle: style), size: CGSize(width: 50, height: 50), icon: image)
            }
        } else {
            return UIImage(named: style == .backgroundColor ? name : name + "-circle")
        }
    #else
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    #endif
    }
    
    func color(forStyle style: ButtonStyle) -> UIColor {
    #if canImport(Combine)
        switch self {
        case .read, .unread: return UIColor.systemBlue
        case .more:
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return UIColor.systemGray
                }
                return style == .backgroundColor ? UIColor.systemGray3 : UIColor.systemGray2
            } else {
                return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
            }
        case .flag: return UIColor.systemOrange
        case .trash: return UIColor.systemRed
        case .edit: return UIColor.systemBlue
        }
    #else
        switch self {
        case .read, .unread, .edit: return #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    #endif
    }
    
    func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        UIBezierPath(ovalIn: rect).addClip()

        color.setFill()
        UIRectFill(rect)

        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }

        defer { UIGraphicsEndImageContext() }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}

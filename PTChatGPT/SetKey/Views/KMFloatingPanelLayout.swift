//
//  KMFloatingPanelLayout.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 20/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import FloatingPanel

class KMFloatingPanelLayout: PTFloatPanelLayout {
    open override var initialState: FloatingPanelState {
        .full
    }

    open override var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring]  {
        [
            .full: FloatingPanelLayoutAnchor(fractionalInset: 0.95, edge: .bottom, referenceGuide: .safeArea),
        ]
    }

    open override var position: FloatingPanelPosition {
        .bottom
    }

    open override func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.45
    }
}

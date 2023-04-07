//
//  PTDiffusionViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 8/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools

@available(iOS 15.4, *)
class PTDiffusionViewController: PTChatBaseViewController {

    let diffusion = MapleDiffusion(saveMemoryButBeSlower: true)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PTGCDManager.gcdBackground {
            PTGCDManager.gcdMain {
                self.diffusion.initModels { progress, step in
                    PTNSLogConsole("\(progress):\(step)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

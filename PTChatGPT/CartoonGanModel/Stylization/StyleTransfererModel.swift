//
//  StyleTransfererModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 25/3/23.
//

import Foundation
import UIKit
import os
import PooTools

// MARK: - StyleTransfererModel
final class StyleTransfererModel {

    // MARK: - Properties

    weak var delegate: ModelDelegate?

    /// Style transferer instance reponsible for running the TF model. Uses a Float16-based model and
    /// runs inference on the GPU.
    private var transferer: StyleTransferer?

    /// Style-representative image applied to the input image to create a pastiche.
    private var styleImage: UIImage?

    func start() {
        self.styleImage = UIImage(named: "DemoImage")
        StyleTransferer.newCPUStyleTransferer { result in
            switch result {
            case .success(let transferer):
                self.transferer = transferer
            case .error(let wrappedError):
                PTNSLogConsole("Failed to initialize: \(wrappedError)")
            }
        }
    }
    
    func process(_ image: UIImage) {

        // Make sure that the style transferer is initialized.
        guard let styleTransferer = transferer else {
            delegate?.model(self, didFailedProcessing: .allocation)
            return
        }

        guard let styleImage = styleImage else {
            delegate?.model(self, didFailedProcessing: .preprocess)
            return
        }

        // 🍉 Run style transfer.
        PTNSLogConsole("Start post-processing 🍉")
        styleTransferer.runStyleTransfer( style: styleImage, image: image, completion: { result in
                // Show the result on screen
            switch result {
            case let .success(styleTransferResult):
                PTNSLogConsole("Finished processing image!")
                self.delegate?.model(self, didFinishProcessing: styleTransferResult.resultImage)
            case .error(_):
                PTNSLogConsole("Could not retrieve output image")
                self.delegate?.model(self, didFailedProcessing: .postprocess)
            }
        })
    }
}

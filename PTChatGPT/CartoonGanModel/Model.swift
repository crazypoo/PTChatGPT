//
//  ModelDelegate.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 25/3/23.
//

import Foundation
import UIKit

enum ModelError: String, Error {
    case allocation = "Failed to initialize the interpreter!"
    case preprocess = "Failed to preprocess the image!"
    case process = "Failed to cartoonize the image!"
    case postprocess = "Failed to process the output!"
    var localizedDescription: String { rawValue }
}


// MARK: - OpenAIModelDelegate
protocol ModelDelegate: NSObject {
    func model(_ model: Any, didFinishProcessing image: UIImage)
    func model(_ model: Any, didFinishAllocation error: ModelError?)
    func model(_ model: Any, didFailedProcessing error: ModelError)
}

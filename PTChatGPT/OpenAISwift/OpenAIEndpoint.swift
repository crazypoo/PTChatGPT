//
//  PTChatViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import Foundation

enum Endpoint {
    case completions
    case edits
    case generateImage
    case chat
}

extension Endpoint {
    var path: String {
        switch self {
        case .completions:
            return "/v1/completions"
        case .edits:
            return "/v1/edits"
        case .generateImage:
            return "/v1/images/generations"
        case .chat:
            return "/v1/chat/completions"
        }
    }
    
    var method: String {
        switch self {
        case .completions, .edits,.generateImage, .chat:
            return "POST"
        }
    }
    
    func baseURL() -> String {
        switch self {
        case .completions, .edits,.generateImage, .chat:
            return "https://api.openai.com"
        }
    }
}

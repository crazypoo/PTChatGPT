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
}

extension Endpoint {
    var path: String {
        switch self {
        case .completions:
            return "/v1/completions"
        case .edits:
            return "/v1/edits"
        }
    }
    
    var method: String {
        switch self {
        case .completions, .edits:
            return "POST"
        }
    }
    
    func baseURL() -> String {
        switch self {
        case .completions, .edits:
            return "https://api.openai.com"
        }
    }
}

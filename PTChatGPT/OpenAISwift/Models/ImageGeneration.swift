//
//  ImageGeneration.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 23/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import Foundation

struct ImageGeneration: Encodable {
    let prompt: String
    let n: Int
    let size: ImageSize
    let user: String?
}

public enum ImageSize: String, Codable {
    case size1024 = "1024x1024"
    case size512 = "512x512"
    case size256 = "256x256"
    
    static var allValues: [ImageSize] {
        return [.size1024, .size512, .size256]
    }
}

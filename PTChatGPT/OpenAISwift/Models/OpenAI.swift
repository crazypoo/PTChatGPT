//
//  OpenAI.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import Foundation

public struct OpenAI: Codable {
    public let object: String
    public let model: String?
    public let choices: [Choice]
}

public struct Choice: Codable {
    public let text: String
}

public struct OpenAIImageGeneration:Codable
{
    struct ImageResponse:Codable
    {
        let url:URL
    }
    let created:Int
    let data:[ImageResponse]
}

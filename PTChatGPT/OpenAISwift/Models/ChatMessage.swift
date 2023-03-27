//
//  ChatMessage.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//


import Foundation

public enum ChatRole: String, Codable {
    case system, user, assistant
}

public struct ChatMessage: Codable {
    public let role: ChatRole
    public let content: String
    
    public init(role: ChatRole, content: String) {
        self.role = role
        self.content = content
    }
}

public struct ChatConversation: Encodable {
    /// The name or identifier of the user who initiates the chat. Optional if not provided by the user interface.
    let user: String?

    /// The messages to generate chat completions for. Ordered chronologically from oldest to newest.
    let messages: [ChatMessage]

    /// The ID of the model used by the assistant to generate responses. See OpenAI documentation for details on which models work with the Chat API.
    let model: String

    /// A parameter that controls how random or deterministic the responses are, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. Optional, defaults to 1.
    let temperature: Double?

    /// A parameter that controls how diverse or narrow-minded the responses are, between 0 and 1. Higher values like 0.9 mean only the tokens comprising the top 90% probability mass are considered, while lower values like 0.1 mean only the top 10%. Optional, defaults to 1.
    let topProbabilityMass: Double?

    /// How many chat completion choices to generate for each input message. Optional, defaults to 1.
    let choices: Int?

    /// An array of up to 4 sequences where the API will stop generating further tokens. Optional.
    let stop: [String]?

    /// The maximum number of tokens to generate in the chat completion. The total length of input tokens and generated tokens is limited by the model's context length. Optional.
    let maxTokens: Int?

    /// A parameter that penalizes new tokens based on whether they appear in the text so far, between -2 and 2. Positive values increase the model's likelihood to talk about new topics. Optional if not specified by default or by user input. Optional, defaults to 0.
    let presencePenalty: Double?

    /// A parameter that penalizes new tokens based on their existing frequency in the text so far, between -2 and 2. Positive values decrease the model's likelihood to repeat the same line verbatim. Optional if not specified by default or by user input. Optional, defaults to 0.
    let frequencyPenalty: Double?

    /// Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID in the OpenAI Tokenizer—not English words) to an associated bias value from -100 to 100. Values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    let logitBias: [Int: Double]?

    enum CodingKeys: String, CodingKey {
        case user
        case messages
        case model
        case temperature
        case topProbabilityMass = "top_p"
        case choices = "n"
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
    }
}

public struct ChatError: Codable {
    public struct Payload: Codable {
        public let message, type, param, code: String
    }
    
    public let error: Payload
}


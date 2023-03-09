//
//  OpenAIModelType.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import Foundation

public enum OpenAIModelType {
    /// ``GPT3``類型
    case gpt3(GPT3)
    
    /// ``Codex``類型
    case codex(Codex)
    
    /// ``Feature``類型
    case feature(Feature)
    
    public var modelName: String {
        switch self {
        case .gpt3(let model): return model.rawValue
        case .codex(let model): return model.rawValue
        case .feature(let model): return model.rawValue
        }
    }
    
    //MARK: 接口相關
    /// [GPT-3 Models OpenAI API Docs](https://beta.openai.com/docs/models/gpt-3)
    public enum GPT3: String {
        
        /// Most capable GPT-3 model. Can do any task the other models can do, often with higher quality, longer output and better instruction-following. Also supports inserting completions within text.
        /// > Model Name: text-davinci-003
        case davinci = "text-davinci-003"
        
        /// Very capable, but faster and lower cost than GPT3 ``davinci``.
        /// > Model Name: text-curie-001
        case curie = "text-curie-001"
        
        /// Capable of straightforward tasks, very fast, and lower cost.
        /// > Model Name: text-babbage-001
        case babbage = "text-babbage-001"
        
        /// Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost.
        /// > Model Name: text-ada-001
        case ada = "text-ada-001"
    }
    
    /// [Codex Models OpenAI API Docs](https://beta.openai.com/docs/models/codex)
    ///
    ///  >  Limited Beta
    public enum Codex: String {
        /// Most capable Codex model. Particularly good at translating natural language to code. In addition to completing code, also supports inserting completions within code.
        ///
        /// > Model Name: code-davinci-002
        case davinci = "code-davinci-002"
        
        /// Almost as capable as ``davinci`` Codex, but slightly faster. This speed advantage may make it preferable for real-time applications.
        ///
        /// > Model Name: code-cushman-001
        case cushman = "code-cushman-001"
    }
    
    
    /// 特定模型
    /// [API Docs](https://beta.openai.com/docs/guides/completion/editing-text)
    public enum Feature: String {
        
        /// > Model Name: text-davinci-edit-001
        case davinci = "text-davinci-edit-001"
    }
}

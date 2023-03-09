//
//  Instruction.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import Foundation

struct Instruction: Encodable {
    let instruction: String
    let model: String
    let input: String
}

//
//  PTAIModerationdModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import KakaJSON

class PTAIModerationdCategory_scores :PTBaseModel {

    required init() {}
    
    var sexual: Double = 0.0
    var sexualMinors: Double = 0.0
    var hateThreatening: Double = 0.0
    var hate: Double = 0.0
    var selfHarm: Double = 0.0
    var violence: Double = 0.0
    var violenceGraphic: Double = 0.0

    open override func kj_modelKey(from property: KakaJSON.Property) -> ModelPropertyKey {
        switch property.name {
        case "sexualMinors":
            return "sexual/minors"
        case "hateThreatening":
            return "hate/threatening"
        case "selfHarm":
            return "self-harm"
        default:
            return property.name
        }
    }
}

class PTAIModerationdCategories :PTBaseModel {
    required init() {}

    var sexual: Bool = false
    var sexualMinors: Bool = false
    var hateThreatening: Bool = false
    var hate: Bool = false
    var selfHarm: Bool = false
    var violence: Bool = false
    var violenceGraphic: Bool = false
    
    open override func kj_modelKey(from property: KakaJSON.Property) -> ModelPropertyKey {
        switch property.name {
        case "sexualMinors":
            return "sexual/minors"
        case "hateThreatening":
            return "hate/threatening"
        case "selfHarm":
            return "self-harm"
        case "violenceGraphic":
            return "violence/graphic"
        default:
            return property.name
        }
    }
}

class PTAIModerationdResults :PTBaseModel {
    var flagged: Bool = false
    var category_scores: PTAIModerationdCategory_scores!
    var categories: PTAIModerationdCategories!
}

class PTAIModerationdModel :PTChatGPTBaseModel {
    var id: String?
    var model: String?
    var results: [PTAIModerationdResults]?
}

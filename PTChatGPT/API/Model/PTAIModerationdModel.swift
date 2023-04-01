//
//  PTAIModerationdModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import HandyJSON

class PTAIModerationdCategory_scores :PTBaseModel {

    required init() {}

    override func mapping(mapper: HelpingMapper) {
        mapper <<<
            sexualMinors <-- "sexual/minors"
        mapper <<<
            hateThreatening <-- "hate/threatening"
        mapper <<<
            selfHarm <-- "self-harm"
        mapper <<<
            violenceGraphic <-- "violence/graphic"
    }
    
    var sexual: Double = 0.0
    var sexualMinors: Double = 0.0
    var hateThreatening: Double = 0.0
    var hate: Double = 0.0
    var selfHarm: Double = 0.0
    var violence: Double = 0.0
    var violenceGraphic: Double = 0.0

}

class PTAIModerationdCategories :PTBaseModel {
    required init() {}

    override func mapping(mapper: HelpingMapper) {
        mapper <<<
            sexualMinors <-- "sexual/minors"
        mapper <<<
            hateThreatening <-- "hate/threatening"
        mapper <<<
            selfHarm <-- "self-harm"
        mapper <<<
            violenceGraphic <-- "violence/graphic"
    }

    var sexual: Bool = false
    var sexualMinors: Bool = false
    var hateThreatening: Bool = false
    var hate: Bool = false
    var selfHarm: Bool = false
    var violence: Bool = false
    var violenceGraphic: Bool = false
}

class PTAIModerationdResults :PTBaseModel {
    var flagged: Bool = false
    var category_scores: PTAIModerationdCategory_scores!
    var categories: PTAIModerationdCategories!
}

class PTAIModerationdModel :PTBaseModel {
    var id: String!
    var model: String!
    var results: [PTAIModerationdResults]!
}

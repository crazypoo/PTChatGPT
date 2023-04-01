//
//  PTChatApiFunction.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import OpenAIKit
import Alamofire
import SwiftSpinner

class PTChatApiFunction: NSObject {
    static let share = PTChatApiFunction()
    
    let baseURL = "https://api.openai.com/v1"
    
    var openAIKIT:OpenAI = {
        let config = Configuration(organizationId: "", apiKey: AppDelegate.appDelegate()!.appConfig.apiToken)
        let openAI = OpenAI(config)
        return openAI
    }()

    func checkSentence(word:String,model:ContentPolicyModels? = .latest,completion:@escaping ((_ model:PTAIModerationdModel?,_ error:AFError?)->Void)) {
                
        SwiftSpinner.show("Checking.....")

        var urlBase = ""

        if AppDelegate.appDelegate()!.appConfig.useCustomDomain {
            urlBase = AppDelegate.appDelegate()!.appConfig.customDomain
        } else {
            urlBase = self.baseURL
        }
        
        let path = "/moderations"
        let param = ["input":word,"model":model!.rawValue]
        let header = HTTPHeaders(["Authorization": "Bearer \(AppDelegate.appDelegate()!.appConfig.apiToken)","Content-Type": "application/json"])
        Network.requestApi(needGobal:false,urlStr: (urlBase + path),header: header,parameters: param,modelType: PTAIModerationdModel.self,encoder: JSONEncoding.default) { result, error in
            SwiftSpinner.hide() {
                if error == nil {
                    if let model = PTAIModerationdModel.deserialize(from: result?.originalString.jsonStringToDic()) {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: "数据解释失败", code: 12345, userInfo: nil) as Error)))
                    }
                } else {
                    PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                    completion(nil,error)
                }
            }
        }
    }
}

//
//  PTChatApiFunction.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 1/4/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import Alamofire
import SwiftSpinner

enum PTOpenAIImageSize:String {
    case size1024 = "1024x1024"
    case size512 = "512x512"
    case size256 = "256x256"
    
    static var allValues : [PTOpenAIImageSize] {
        return [.size1024, .size512, .size256]
    }
}

public enum ContentPolicyModels: String, Codable {
    /// The latest model that gets automatically upgraded over time.
    case latest = "text-moderation-latest"
    
    /// The stable model that gets prior notification before being upgraded.
    case stable = "text-moderation-stable"
}

class PTChatApiFunction: NSObject {
    static let share = PTChatApiFunction()
    
    let baseURL = "https://api.openai.com/v1"
    let baseHeader = HTTPHeaders(["Authorization": "Bearer \(AppDelegate.appDelegate()!.appConfig.apiToken)","Content-Type": "application/json"])
    
    let jsonSerializationFailedError = NSError(domain: "数据解释失败", code: 12345, userInfo: nil)
    
    func fullUrlPath(path:String) -> String {
        var urlBase = ""

        if AppDelegate.appDelegate()!.appConfig.useCustomDomain {
            urlBase = AppDelegate.appDelegate()!.appConfig.customDomain
        } else {
            urlBase = self.baseURL
        }
        return (urlBase + path)
    }
    
    func checkSentence(word:String,model:ContentPolicyModels? = .latest,completion:@escaping ((_ model:PTAIModerationdModel?,_ error:AFError?)->Void)) {
                
        SwiftSpinner.show("Checking.....")
        
        let path = self.fullUrlPath(path: "/moderations")
        let param = ["input":word,"model":model!.rawValue]
        Network.requestApi(needGobal:false,urlStr: path,header: self.baseHeader,parameters: param,modelType: PTAIModerationdModel.self,encoder: JSONEncoding.default,showHud: false) { result, error in
            SwiftSpinner.hide() {
                if error == nil {
                    if let model = PTAIModerationdModel.deserialize(from: result?.originalString.jsonStringToDic()) {
                        if model.error == nil {
                            completion(model,nil)
                        } else {
                            completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                        }
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                    }
                } else {
                    PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                    completion(nil,error)
                }
            }
        }
    }
    
    func sendCompletions(prompt:String,modelType: OpenAIModelType = .gpt3(.davinci),temperature:Double? = 1,maxTokens: Int = 16,completion:@escaping ((_ model:PTAICompletionsModel?,_ error:AFError?)->Void)) {
        let path = self.fullUrlPath(path: "/completions")
        let param = ["prompt":prompt,"model":modelType.modelName,"max_tokens":maxTokens,"temperature":temperature!] as [String : Any]
        Network.requestApi(needGobal:false,urlStr: path,header: self.baseHeader,parameters: param,encoder: JSONEncoding.default,showHud: false) { result, error in
            if error == nil {
                if let model = PTAICompletionsModel.deserialize(from: result?.originalString.jsonStringToDic()) {
                    if model.error == nil {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                    }
                } else {
                    completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                }
            } else {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                completion(nil,error)
            }
        }
    }
    
    func sendEdits(input:String,instruction:String,modelType: OpenAIModelType = .feature(.davinci),completion:@escaping ((_ model:PTAIEditsModel?,_ error:AFError?)->Void)) {
        let path = self.fullUrlPath(path: "/edits")
        let param = ["input":input,"model":modelType.modelName,"instruction":instruction] as [String : Any]
        Network.requestApi(needGobal:false,urlStr: path,header: self.baseHeader,parameters: param,encoder: JSONEncoding.default,showHud: false) { result, error in
            if error == nil {
                if let model = PTAIEditsModel.deserialize(from: result?.originalString.jsonStringToDic()) {
                    if model.error == nil {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                    }
                } else {
                    completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                }
            } else {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                completion(nil,error)
            }
        }
    }
        
    func sendChat(sendModel:PTSendChatModel,completion:@escaping ((_ model:PTReceiveChatModel?,_ error:AFError?)->Void)) {
        let path = self.fullUrlPath(path: "/chat/completions")
        let param = sendModel.toJSON()
        Network.requestApi(needGobal:false,urlStr: path,header: self.baseHeader,parameters: param,encoder: JSONEncoding.default,showHud: false) { result, error in
            if error == nil {
                if let model = PTReceiveChatModel.deserialize(from: result?.originalString.jsonStringToDic()) {
                    if model.error == nil {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                    }
                } else {
                    completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                }
            } else {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                completion(nil,error)
            }
        }
    }
}

//MARK: 图片类
extension PTChatApiFunction {
    func imageGenerations(prompt:String,@PTClampedProperyWrapper(range: 1...10) numberofImages: Int = 1,imageSize:PTOpenAIImageSize,completion:@escaping ((_ model:PTImageGeneration?,_ error:AFError?)->Void)) {
        let path = self.fullUrlPath(path: "/images/generations")
        let param = ["prompt":prompt,"n":numberofImages,"size":imageSize.rawValue] as [String : Any]
        Network.requestApi(needGobal:false,urlStr: path,header: self.baseHeader,parameters: param,encoder: JSONEncoding.default,showHud: false) { result, error in
            if error == nil {
                if let model = PTImageGeneration.deserialize(from: result?.originalString.jsonStringToDic()) {
                    if model.error == nil {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                    }
                } else {
                    completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                }
            } else {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                completion(nil,error)
            }
        }
    }
    
    func imageVariation(image:UIImage,@PTClampedProperyWrapper(range: 1...10) numberofImages: Int = 1,imageSize:PTOpenAIImageSize,completion:@escaping ((_ model:PTImageGeneration?,_ error:AFError?)->Void)) {
        let path = self.fullUrlPath(path: "/images/variations")
        let param = ["n":"\(numberofImages)","size":imageSize.rawValue]
        
        let baseHeader = HTTPHeaders(["Authorization": "Bearer \(AppDelegate.appDelegate()!.appConfig.apiToken)","Content-Type": "multipart/form-data; boundary=\(UUID().uuidString)"])

        Network.imageUpload(needGobal:false,images: [image],path: path,fileKey: ["image"],parmas: param,header: baseHeader,showHud: false) { result, error in
            if error == nil {
                if let model = PTImageGeneration.deserialize(from: result?.originalString.jsonStringToDic()) {
                    if model.error == nil {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                    }
                } else {
                    completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                }
            } else {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                completion(nil,error)
            }
        }
    }
    
    func editImage(prompt:String,mainImage:UIImage,maskImage:UIImage? = nil,@PTClampedProperyWrapper(range: 1...10) numberofImages: Int = 1,imageSize:PTOpenAIImageSize,completion:@escaping ((_ model:PTImageGeneration?,_ error:AFError?)->Void)) {
        let path = self.fullUrlPath(path: "/images/edits")
        let param = ["prompt":prompt,"n":"\(numberofImages)","size":imageSize.rawValue]
        
        let baseHeader = HTTPHeaders(["Authorization": "Bearer \(AppDelegate.appDelegate()!.appConfig.apiToken)","Content-Type": "multipart/form-data; boundary=\(UUID().uuidString)"])

        var images = [UIImage]()
        var imagesName = [String]()
        if maskImage != nil {
            images = [mainImage,maskImage!]
            imagesName = ["image","mask"]
        } else {
            images = [mainImage]
            imagesName = ["image"]
        }
        
        Network.imageUpload(needGobal:false,images: images,path: path,fileKey: imagesName,parmas: param,header: baseHeader,showHud: false) { result, error in
            if error == nil {
                if let model = PTImageGeneration.deserialize(from: result?.originalString.jsonStringToDic()) {
                    if model.error == nil {
                        completion(model,nil)
                    } else {
                        completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError(domain: model.error!.message, code: 12345, userInfo: nil))))
                    }
                } else {
                    completion(nil,AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: self.jsonSerializationFailedError)))
                }
            } else {
                PTBaseViewController.gobal_drop(title: error!.localizedDescription)
                completion(nil,error)
            }
        }
    }

}

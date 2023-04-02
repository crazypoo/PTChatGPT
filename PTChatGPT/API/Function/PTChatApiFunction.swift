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

class PTChatApiFunction {
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
    
    //MARK: ChatGPT的文明用语检测
    ///ChatGPT的文明用语检测
    /// - Parameters:
    ///   - word: 须要检测的文本
    ///   - model: GPT的检测模型,因为这里只能用到ContentPolicyModels里面的Case模型
    func checkSentence(word:String,
                       model:ContentPolicyModels? = .latest,
                       completion:@escaping ((_ model:PTAIModerationdModel?,_ error:AFError?)->Void)) {
                
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
}

//MARK: 编辑
extension PTChatApiFunction {
    //MARK: ChatGPT修改文本接口请求
    ///ChatGPT修改文本接口请求
    /// - Parameters:
    ///   - input: 须要修改的内容
    ///   - instruction: 参照内容
    ///   - modelType: 模型(这里的模型智能是GPT3.5以下的模型)
    func sendEdits(input:String,
                   instruction:String,
                   modelType: OpenAIModelType = .feature(.davinci),
                   completion:@escaping ((_ model:PTAIEditsModel?,_ error:AFError?)->Void)) {
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
}

//MARK: 发送信息
extension PTChatApiFunction {
    //MARK: ChatGPT发送消息请求
    ///ChatGPT发送消息请求
    /// - Parameters:
    ///   - prompt: 问题内容
    ///   - modelType: 模型
    ///   - temperature: GPT的智障程度
    ///   - maxTokens: 消耗的TOKEN
    func sendCompletions(prompt:String,
                         modelType: OpenAIModelType = .gpt3(.davinci),
                         temperature:Double? = 1,
                         maxTokens: Int = 16,
                         completion:@escaping ((_ model:PTAICompletionsModel?,_ error:AFError?)->Void)) {
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

    //MARK: ChatGPT发送消息请求(GPT3.5以上的接口请求)
    ///ChatGPT发送消息请求(GPT3.5以上的接口请求)
    /// - Parameters:
    ///   - sendModel: 消息模型
    func sendChat(sendModel:PTSendChatModel,
                  completion:@escaping ((_ model:PTReceiveChatModel?,_ error:AFError?)->Void)) {
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
    //MARK: ChatGPT根据内容来生成图片
    ///ChatGPT根据内容来生成图片
    /// - Parameters:
    ///   - prompt: 须要画画的需求
    ///   - numberofImages: 图片数量(为什么要用到这种特殊的方法,是因为这个方法可以控制图片的数量范围,不会超出范围)
    ///   - imageSize: 图片大小(这里ChatGPT有限制图片必须是1024*1024/512*512/256*256)
    func imageGenerations(prompt:String,
    @PTClampedProperyWrapper(range: 1...10) numberofImages: Int = 1,
imageSize:PTOpenAIImageSize,
completion:@escaping ((_ model:PTImageGeneration?,_ error:AFError?)->Void)) {
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
    
    //MARK: ChatGPT根据图片来生成相似的图片
    ///ChatGPT根据图片来生成相似的图片
    /// - Parameters:
    ///   - imageVariation: 需求图片
    ///   - numberofImages: 图片数量(为什么要用到这种特殊的方法,是因为这个方法可以控制图片的数量范围,不会超出范围)
    ///   - imageSize: 图片大小(这里ChatGPT有限制图片必须是1024*1024/512*512/256*256)
    func imageVariation(image:UIImage,
    @PTClampedProperyWrapper(range: 1...10) numberofImages: Int = 1,
imageSize:PTOpenAIImageSize,
completion:@escaping ((_ model:PTImageGeneration?,_ error:AFError?)->Void)) {
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
    
    //MARK: ChatGPT根据图片和需求和遮罩图片来帮你PS图片
    ///ChatGPT根据图片和需求和遮罩图片来帮你PS图片
    /// - Parameters:
    ///   - editImage: 需求内容
    ///   - mainImage: 主图(须要PS的图片)
    ///   - maskImage: 遮罩图片(可以是空)
    ///   - imageSize: 图片大小(这里ChatGPT有限制图片必须是1024*1024/512*512/256*256)
    ///   - numberofImages: 图片数量
    func editImage(prompt:String,
mainImage:UIImage,
maskImage:UIImage? = nil,
    @PTClampedProperyWrapper(range: 1...10) numberofImages: Int = 1,
imageSize:PTOpenAIImageSize,
completion:@escaping ((_ model:PTImageGeneration?,_ error:AFError?)->Void)) {
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

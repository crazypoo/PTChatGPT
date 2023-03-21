//
//  PTChatViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import Foundation
#if canImport(FoundationNetworking) && canImport(FoundationXML)
import FoundationNetworking
import FoundationXML
#endif

public enum OpenAIError: Error {
    case genericError(error: Error)
    case decodingError(error: Error)
}

public class OpenAISwift {
    fileprivate(set) var token: String?
    
    public init(authToken: String) {
        self.token = authToken
    }
}

extension OpenAISwift {
    //MARK: 發送內容到OpenAI API
    ///發送內容到OpenAI API
    /// - Parameters:
    ///   - prompt: 內容
    ///   - model: OpenAI模型,默認`OpenAIModelType.gpt3(.davinci)`
    ///   - maxTokens: 返回响应的限制字符，根据API默认为16
    ///   - temperature: 较高的值(如0.8)将使输出更加随机，而较低的值(如0.2)将使输出更加集中和确定。默认值为1
    ///   - completionHandler: 返回OpenAI模型
    public func sendCompletion(with prompt: String, model: OpenAIModelType = .gpt3(.davinci), maxTokens: Int = 16, temperature: Double = 1, completionHandler: @escaping (Result<OpenAI<TextResult>, OpenAIError>) -> Void) {
        let endpoint = Endpoint.completions
        let body = Command(prompt: prompt, model: model.modelName, maxTokens: maxTokens, temperature: temperature)
        let request = prepareRequest(endpoint, body: body)
        
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(OpenAI<TextResult>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    //MARK: 讓OpenAI修改
    ///讓OpenAI修改
    /// - Parameters:
    ///   - instruction: 需求填寫
    ///   - model: 只支持`text-davinci-edit-001`
    ///   - input: 內容
    ///   - completionHandler: 返回OpenAI模型
    public func sendEdits(with instruction: String, model: OpenAIModelType = .feature(.davinci), input: String = "", completionHandler: @escaping (Result<OpenAI<TextResult>, OpenAIError>) -> Void) {
        let endpoint = Endpoint.edits
        let body = Instruction(instruction: instruction, model: model.modelName, input: input)
        let request = prepareRequest(endpoint, body: body)
        
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(OpenAI<TextResult>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
        
    /// Send a Chat request to the OpenAI API
    /// - Parameters:
    ///   - messages: Array of `ChatMessages`
    ///   - model: The Model to use, the only support model is `gpt-3.5-turbo`
    ///   - maxTokens: used in OpenAI's text-generating API to specify the maximum number of tokens (words) that should be generated in response to a prompt. This parameter is used to prevent the model from generating excessively long or rambling responses that may not be relevant to the prompt. The actual length of the response may be shorter than the `maxTokens` value if the model determines that it has reached a natural stopping point in the generation process.
    ///   - temperature: a value that determines the level of creativity and diversity in the output of the API. Temperature values closer to 0 will generate more predictable and conservative output, while higher temperature values will generate more original and surprising output. Essentially, the temperature value controls the randomness or "playfulness" of the generated text. It is measured in units of degrees Celsius and typically ranges from 0.1 to 1.0, with higher values producing more unexpected and diverse output.
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendChat(with messages: [ChatMessage], model: OpenAIModelType = .chat(.chatgpt), maxTokens: Int? = nil, temperature: Double = 1.0, completionHandler: @escaping (Result<OpenAI<MessageResult>, OpenAIError>) -> Void) {
        let endpoint = Endpoint.chat
        let body = ChatConversation(messages: messages, model: model.modelName, maxTokens: maxTokens, temperature: temperature)
        let request = prepareRequest(endpoint, body: body)
        
        makeRequest(request: request) { result in
            switch result {
                case .success(let success):
                    do {
                        let res = try JSONDecoder().decode(OpenAI<MessageResult>.self, from: success)
                        completionHandler(.success(res))
                    } catch {
                        completionHandler(.failure(.decodingError(error: error)))
                    }
                case .failure(let failure):
                    completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    public func getImages(with prompt:String,imageSize:CGSize,completionHandler: @escaping ((Result<OpenAIImageGeneration, OpenAIError>)) -> Void) {
        let sizeString = String(format: "%.0fx%.0f", imageSize.width,imageSize.height)
        let endpoint = Endpoint.generateImage
        let parameters: [String: Any] = [
            "prompt" : prompt,
            "n" : 1,
            "size" : sizeString,
            "user" : UUID().uuidString
        ]
        
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL())!, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path

        do {
            let data: Data = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: urlComponents!.url!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completionHandler(.failure(.genericError(error: error)))
                } else if let data = data {
                    do {
                        let result = try JSONDecoder().decode(OpenAIImageGeneration.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(.decodingError(error: error)))
                    }
                }
            }
            
            task.resume()
        } catch {
            completionHandler(.failure(.genericError(error: error)))
        }
    }

    
    private func makeRequest(request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else if let data = data {
                completionHandler(.success(data))
            }
        }
        
        task.resume()
    }
    
    private func prepareRequest<BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL())!, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = endpoint.method
        
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(body) {
            request.httpBody = encoded
        }
        
        return request
    }
}

extension OpenAISwift {
    /// 發送內容到OpenAI API
    /// - Parameters:
    ///   - prompt: 內容
    ///   - model: OpenAI模型,默認`OpenAIModelType.gpt3(.davinci)`
    ///   - maxTokens: 返回响应的限制字符，根据API默认为16
    ///   - temperature: 较高的值(如0.8)将使输出更加随机，而较低的值(如0.2)将使输出更加集中和确定。默认值为1
    /// - Returns: 返回OpenAI模型
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendCompletion(with prompt: String, model: OpenAIModelType = .gpt3(.davinci), maxTokens: Int = 16, temperature: Double = 1) async throws -> OpenAI<TextResult> {
        return try await withCheckedThrowingContinuation { continuation in
            sendCompletion(with: prompt, model: model, maxTokens: maxTokens, temperature: temperature) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    //MARK: 讓OpenAI修改
    ///讓OpenAI修改
    /// - Parameters:
    ///   - instruction: 需求填寫
    ///   - model: 只支持`text-davinci-edit-001`
    ///   - input: 內容
    ///   - completionHandler: 返回OpenAI模型
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendEdits(with instruction: String, model: OpenAIModelType = .feature(.davinci), input: String = "", completionHandler: @escaping (Result<OpenAI<TextResult>, OpenAIError>) -> Void) async throws -> OpenAI<TextResult> {
        return try await withCheckedThrowingContinuation { continuation in
            sendEdits(with: instruction, model: model, input: input) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Send a Chat request to the OpenAI API
    /// - Parameters:
    ///   - messages: Array of `ChatMessages`
    ///   - model: The Model to use, the only support model is `gpt-3.5-turbo`
    ///   - maxTokens: used in OpenAI's text-generating API to specify the maximum number of tokens (words) that should be generated in response to a prompt. This parameter is used to prevent the model from generating excessively long or rambling responses that may not be relevant to the prompt. The actual length of the response may be shorter than the `maxTokens` value if the model determines that it has reached a natural stopping point in the generation process.
    ///   - temperature: a value that determines the level of creativity and diversity in the output of the API. Temperature values closer to 0 will generate more predictable and conservative output, while higher temperature values will generate more original and surprising output. Essentially, the temperature value controls the randomness or "playfulness" of the generated text. It is measured in units of degrees Celsius and typically ranges from 0.1 to 1.0, with higher values producing more unexpected and diverse output.
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendChat(with messages: [ChatMessage], model: OpenAIModelType = .chat(.chatgpt), maxTokens: Int? = nil, temperature: Double = 1.0) async throws -> OpenAI<MessageResult> {
        return try await withCheckedThrowingContinuation { continuation in
            sendChat(with: messages, model: model, maxTokens: maxTokens, temperature: temperature) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func getImages(with prompt:String,imageSize:CGSize) async throws -> OpenAIImageGeneration {
        let sizeString = String(format: "%.0fx%.0f", imageSize.width,imageSize.height)
        let endpoint = Endpoint.generateImage
        let parameters: [String: Any] = [
            "prompt" : prompt,
            "n" : 1,
            "size" : sizeString,
            "user" : UUID().uuidString
        ]
        
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL())!, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path

        let data: Data = try JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: urlComponents!.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = data
        let (response, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(OpenAIImageGeneration.self, from: response)
        return result
    }
}

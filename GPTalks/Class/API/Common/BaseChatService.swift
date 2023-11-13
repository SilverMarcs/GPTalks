//
//  OpenAIService.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI

protocol ChatService {
    var baseURL: String { get }
    var path: String { get }
    var method: String {  get }
    var headers: [String: String] { get }
    var session: DialogueSession { get set }

    func makeRequest(with conversations: [Conversation], stream: Bool) throws -> URLRequest
    func createTitle() async throws -> String
    func makeJSONBody(with conversations: [Conversation], stream: Bool) throws -> Data
    func sendMessage(_ conversations: [Conversation]) async throws -> AsyncThrowingStream<String, Error>
    func sendMessageStream(_ conversations: [Conversation]) async throws -> AsyncThrowingStream<String, Error>
}

class BaseChatService: @unchecked Sendable, ChatService {
    var session: DialogueSession
    
    required init(session: DialogueSession) {
        self.session = session
    }
    
    var configuration: DialogueSession.Configuration {
        session.configuration
    }
    
    var baseURL: String {
        return ""
    }
    
    var path: String {
        return ""
    }
    
    var method: String = "POST"
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func makeRequest(with conversations: [Conversation], stream: Bool = false) throws -> URLRequest {
        let url = URL(string: baseURL + path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        urlRequest.httpBody = try makeJSONBody(with: conversations, stream: stream)
        return urlRequest
    }
    
    var headers: [String: String] {
        [:]
    }
    
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    func createTitle() async throws -> String {
        try await sendTaskMessage("Give me a title of this conversation. Make it as short as possible. Your title should NOT exceed 4 words. Send the title only and nothing else. Do not include quotation symbols. Do not add your own words unless it is the title only")
    }
    
    func makeJSONBody(with conversations: [Conversation], stream: Bool = true) throws -> Data {
        let request = Chat(model: configuration.model.id,
                           temperature: configuration.temperature,
                           messages:  conversations.map { $0.toMessage() },
                           stream: stream,
                           max_tokens: configuration.model.maxTokens)
        return try JSONEncoder().encode(request)
    }
    
    func sendMessage(_ conversations: [Conversation]) async throws -> AsyncThrowingStream<String, Error> {
        
        do {
            return try await sendMessageStream(conversations)
        } catch {
            throw error
        }
    }

    
    func sendMessageStream(_ conversations: [Conversation]) async throws -> AsyncThrowingStream<String, Error> {
        let urlRequest = try makeRequest(with: conversations, stream: true)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw String(localized: "Invalid response")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                try Task.checkCancellation()
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            throw String(localized: "Response Error: \(httpResponse.statusCode), \(errorText)")
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            session.streamingTask = Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    var reply = ""
                    for try await line in result.lines {
                        try Task.checkCancellation()
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            reply += text
                            continuation.yield(text)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // TODO: this is flawed. need to summarize whole convo
    func sendTaskMessageStream(_ taskPrompt: String, messageText: String? = nil, temperature: Double = 0) async throws -> AsyncThrowingStream<String, Error> {
        let messages = [
            Message(role: "system", content: configuration.systemPrompt),
            Message(role: "user", content: taskPrompt)
        ]
        
        let url = URL(string: baseURL + path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        let requestModel = Chat(model: configuration.model.id, temperature: temperature,
                                messages: messages, stream: true, max_tokens: configuration.model.maxTokens)
        urlRequest.httpBody = try JSONEncoder().encode(requestModel)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw String(localized: "Invalid response")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw String(localized: "Response Error: \(httpResponse.statusCode), \(errorText)")
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    var reply = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            reply += text
                            continuation.yield(text)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // TODO: this is flawed. need to summarize whole convo
    func sendTaskMessage(_ text: String) async throws -> String {
        let url = URL(string: baseURL + path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        let requestModel = Chat(model: configuration.model.id, 
                                temperature: 0.8,
                                messages: [Message(role: "user", content: text)],
                                stream: false,
                                max_tokens: 100)
        urlRequest.httpBody = try JSONEncoder().encode(requestModel)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw String(localized: "Invalid response")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var error = String(localized: "Response Error: \(httpResponse.statusCode)")
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try jsonDecoder.decode(CompletionResponse.self, from: data)
            let reply = completionResponse.choices.first?.message.content ?? ""
            return reply
        } catch {
            throw error
        }
    }
   
}

extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    
}

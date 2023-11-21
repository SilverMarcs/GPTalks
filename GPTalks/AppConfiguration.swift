//
//  AppConfiguration.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

class AppConfiguration: ObservableObject {
    
    static let shared = AppConfiguration()
    
    /// common
    @AppStorage("configuration.rapidApiKey") var rapidApiKey = ""
    
    @AppStorage("configuration.isMarkdownEnabled") var isMarkdownEnabled: Bool = true
    
    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = false
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: Provider = .openai
    
    @AppStorage("configuration.contextLength") var contextLength = 20
    
    @AppStorage("configuration.temperature") var temperature: Double = 0.8
    
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.model") var OAImodel: Model = .gpt3t
    
    /// openRouter
    @AppStorage("configuration.ORKey") var ORkey = ""
    @AppStorage("configuration.ORmodel") var ORmodel: Model = .orphind
    
    /// naga
    @AppStorage("configuration.Nkey") var Nkey = ""
    @AppStorage("configuration.Nmodel") var Nmodel: Model = .gpt4t
    
    /// bing
    @AppStorage("configuration.Bkey") var Bkey = ""
    @AppStorage("configuration.Bmodel") var Bmodel: Model = .gpt3t
    
}

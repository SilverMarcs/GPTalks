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
    
    @AppStorage("configuration.contextLength") var contextLength = 30
    
    @AppStorage("configuration.temperature") var temperature: Double = 0.8
    
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.model") var model: Model = .gpt3t
    
    /// openRouter
    @AppStorage("configuration.ORKey") var ORkey = ""
    @AppStorage("configuration.ORmodel") var ORmodel: Model = .orphind
    
    /// custom
    @AppStorage("configuration.Nkey") var Nkey = ""
    @AppStorage("configuration.Nmodel") var Nmodel: Model = .gpt4t
    
    /// custom2
    @AppStorage("configuration.C2Key") var Ckey = ""
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .gpt3t
    
}

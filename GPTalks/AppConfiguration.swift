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
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: AIProvider = .openai
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    
    @AppStorage("configuration.OAIcontextLength") var OAIcontextLength = 30
    
    @AppStorage("configuration.OAItemperature") var OAItemperature: Double = 0.8
    
    @AppStorage("configuration.OAIsystemPrompt") var OAIsystemPrompt: String = "You are a helpful assistant."
    
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt3t
    
    /// openRouter
    @AppStorage("configuration.ORKey") var ORkey = ""
    
    @AppStorage("configuration.ORcontextLength") var ORcontextLength = 30
    
    @AppStorage("configuration.ORtemperature") var ORtemperature: Double = 0.8
    
    @AppStorage("configuration.ORsystemPrompt") var ORsystemPrompt: String = "You are a helpful assistant."
    
    @AppStorage("configuration.ORmodel") var ORmodel: Model = .orphind
    
    /// custom
    @AppStorage("configuration.CKey") var Ckey = ""
    
    @AppStorage("configuration.CcontextLength") var CcontextLength = 30
    
    @AppStorage("configuration.Ctemperature") var Ctemperature: Double = 0.8
    
    @AppStorage("configuration.CsystemPrompt") var CsystemPrompt: String = "You are a helpful assistant."
    
    @AppStorage("configuration.CHost") var CHost: String = ""
    
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .gpt3t

}

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
    
    @AppStorage("configuration.CHost") var Chost: String = ""
    
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .gpt3t
    
    /// custom2
    @AppStorage("configuration.C2Key") var C2key = ""
    
    @AppStorage("configuration.C2contextLength") var C2contextLength = 30
    
    @AppStorage("configuration.C2temperature") var C2temperature: Double = 0.8
    
    @AppStorage("configuration.C2systemPrompt") var C2systemPrompt: String = "You are a helpful assistant."
    
    @AppStorage("configuration.C2Host") var C2host: String = ""
    
    @AppStorage("configuration.C2model") var C2model: Model = .gpt3t

}

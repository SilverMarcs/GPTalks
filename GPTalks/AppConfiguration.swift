//
//  AppConfiguration.swift
//  GPTalks
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
    
    @AppStorage("configuration.temperature") var temperature: Double = 0.5
    
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."
    
    @AppStorage("configuration.ignore_web") var ignoreWeb: String = "False"
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt3
    
    /// openRouter
    @AppStorage("configuration.ORKey") var ORkey = ""
    @AppStorage("configuration.ORmodel") var ORmodel: Model = .orzephyr
    
    /// naga
    @AppStorage("configuration.Nkey") var Nkey = ""
    @AppStorage("configuration.Nmodel") var Nmodel: Model = .gpt4
    
    /// mandril
    @AppStorage("configuration.Mkey") var Mkey = ""
    @AppStorage("configuration.Mmodel") var Mmodel: Model = .gpt4
    
    /// gpt4free
    @AppStorage("configuration.Gkey") var Gkey = ""
    @AppStorage("configuration.Gmodel") var Gmodel: Model = .gpt4
    @AppStorage("configuration.Ghost") var Ghost: String = ""
    
    /// custom
    @AppStorage("configuration.Ckey") var Ckey = ""
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .gpt4
    @AppStorage("configuration.Chost") var Chost: String = ""
}

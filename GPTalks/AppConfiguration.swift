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
    
    @AppStorage("configuration.isMarkdownEnabled") var isMarkdownEnabled: Bool = true
    @AppStorage("configuration.alternateMarkdwon") var alternateMarkdown: Bool = false
    
//    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = false
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: Provider = .openai
    @AppStorage("configuration.preferredImageService") var preferredImageService: Provider = .openai
    
    // config
    @AppStorage("configuration.contextLength") var contextLength = 20
    @AppStorage("configuration.temperature") var temperature: Double = 0.5
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."    
    @AppStorage("configuration.ignore_web") var ignoreWeb: String = "False"
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt3t0125
    
    /// openRouter
    @AppStorage("configuration.ORKey") var ORkey = ""
    @AppStorage("configuration.ORmodel") var ORmodel: Model = .ortoppy
    
    /// shuttle
    @AppStorage("configuration.Skey") var Skey = ""
    @AppStorage("configuration.Smodel") var Smodel: Model = .gpt4t1106
    
    /// oxygen
    @AppStorage("configuration.Okey") var Okey = ""
    @AppStorage("configuration.Omodel") var Omodel: Model = .gpt4t1106
    
    /// gpt4free
    @AppStorage("configuration.Gkey") var Gkey = ""
    @AppStorage("configuration.Gmodel") var Gmodel: Model = .gpt4
    @AppStorage("configuration.Ghost") var Ghost: String = ""
    
    /// custom
    @AppStorage("configuration.Ckey") var Ckey = ""
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .gpt4t1106
    @AppStorage("configuration.Chost") var Chost: String = ""
    
    @AppStorage("configuration.customModel") var customModel: String = ""
    @AppStorage("configuration.defaultImageModel") var defaultImageModel: String = "dall-e-3"
    @AppStorage("configuration.customVisionModel") var customVisionModel: String = "shuttle-turbo"
}

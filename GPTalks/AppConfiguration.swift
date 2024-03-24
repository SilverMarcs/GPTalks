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
    @AppStorage("configuration.alternateMarkdown") var alternateMarkdown: Bool = false
    
    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = true
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: Provider = .openai
    @AppStorage("configuration.preferredImageService") var preferredImageService: Provider = .openai
    
    // Google Search
    @AppStorage("configuration.googleApiKey") var googleApiKey = ""
    @AppStorage("configuration.googleSearchEngineId") var googleSearchEngineId = ""
    
    // config
    @AppStorage("configuration.contextLength") var contextLength = 10
    @AppStorage("configuration.temperature") var temperature: Double = 0.5
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."    
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt3t
    @AppStorage("configuration.OAIImageModel") var OAIImageModel: Model = .dalle3

    /// oxygen
    @AppStorage("configuration.Okey") var Okey = ""
    @AppStorage("configuration.Omodel") var Omodel: Model = .gpt4t
    @AppStorage("configuration.OImageModel") var OImageModel: Model = .dalle3
    
    /// naga
    @AppStorage("configuration.Nkey") var Nkey = ""
    @AppStorage("configuration.Nmodel") var Nmodel: Model = .gpt4t
    @AppStorage("configuration.NImageModel") var NImageModel: Model = .dalle3
    
    /// kraken
    @AppStorage("configuration.Kkey") var Kkey = ""
    @AppStorage("configuration.Kmodel") var Kmodel: Model = .gpt4
    @AppStorage("configuration.KImageModel") var KImageModel: Model = .dalle3
    
    /// custom
    @AppStorage("configuration.Ckey") var Ckey = ""
    @AppStorage("configuration.Chost") var Chost: String = ""
    
    @AppStorage("configuration.customChatModel") var customChatModel: String = ""
    @AppStorage("configuration.customImageModel") var customImageModel: String = ""
    @AppStorage("configuration.customVisionModel") var customVisionModel: String = ""
}

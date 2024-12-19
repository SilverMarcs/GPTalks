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
    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = true
    @AppStorage("configuration.autoResume") var autoResume: Bool = true
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: Provider = .openai
    @AppStorage("configuration.preferredImageService") var preferredImageService: Provider = .openai
    
    // params
    @AppStorage("configuration.contextLength") var contextLength = 10
    @AppStorage("configuration.temperature") var temperature: Double = 0.5
    @AppStorage("configuration.useTools") var useTools: Bool = true
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt4o
    @AppStorage("configuration.OAIImageModel") var OAIImageModel: Model = .dalle3
    @AppStorage("configuration.OAIColor") var OAIColor: ProviderColor = .greenColor

    
    /// custom
    @AppStorage("configuration.Ckey") var Ckey = ""
    @AppStorage("configuration.Chost") var Chost: String = ""
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .customChat
    @AppStorage("configuration.CImageModel") var CImageModel: Model = .dalle3
    @AppStorage("configuration.CColor") var CColor: ProviderColor = .orangeColor
    
    @AppStorage("configuration.customChatModel") var customChatModel: String = ""
    @AppStorage("configuration.customImageModel") var customImageModel: String = ""
    @AppStorage("configuration.customVisionModel") var customVisionModel: String = ""
    
}

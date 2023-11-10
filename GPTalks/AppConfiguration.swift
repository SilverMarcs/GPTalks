//
//  AppConfiguration.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

class AppConfiguration: ObservableObject {
    
    static let shared = AppConfiguration()
    
    /// common
    @AppStorage("configuration.rapidApiKey") var rapidApiKey = ""
    
    @AppStorage("configuration.isMarkdownEnabled") var isMarkdownEnabled: Bool = true
    
    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = false
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: AIProvider = .openAI
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    
    @AppStorage("configuration.OAIcontextLength") var OAIcontextLength = 30
    
    @AppStorage("configuration.OAItemperature") var OAItemperature: Double = 0.8
    
    @AppStorage("configuration.OAIsystemPrompt") var OAIsystemPrompt: String = "You are a helpful assistant."
    
    /// openRouter
    @AppStorage("configuration.ORKey") var ORkey = ""
    
    @AppStorage("configuration.ORcontextLength") var ORcontextLength = 30
    
    @AppStorage("configuration.ORtemperature") var ORtemperature: Double = 0.8
    
    @AppStorage("configuration.ORsystemPrompt") var ORsystemPrompt: String = "You are a helpful assistant."

}

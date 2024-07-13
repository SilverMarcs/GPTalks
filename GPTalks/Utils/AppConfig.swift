//
//  AppConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
    // General
    @AppStorage("assistantMarkdown") var assistantMarkdown: Bool = true
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("compactList") var compactList: Bool = false
    
    // Parameters
    @AppStorage("temperature") var temperature: Double = 1.0
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."
}

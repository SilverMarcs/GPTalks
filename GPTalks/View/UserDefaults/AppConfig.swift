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
    
    // Quick
    @AppStorage("configuration.quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses extremeley concise."
    
    // Misc
    @AppStorage("sidebarFocus") var sidebarFocus: Bool = false
    
}

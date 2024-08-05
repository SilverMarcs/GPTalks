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
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .webview
    
    @AppStorage("compactList") var compactList: Bool = false
    
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    
    // Quick
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses extremeley concise."
    
    // Misc
    @AppStorage("sidebarFocus") var sidebarFocus: Bool = false
    
}


enum MarkdownProvider: String, Codable, CaseIterable {
    case webview
    case native
    case disabled
    
    var name: String {
        switch self {
        case .webview: "WebView"
        case .native: "Native"
        case .disabled: "Disabled"
        }
    }
}

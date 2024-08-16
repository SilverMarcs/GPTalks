//
//  AppConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import MarkdownWebView

class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
    // Appearance
    @AppStorage("fontSize") var fontSize: Double = 13
    
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .webview
    @AppStorage("compactList") var compactList: Bool = false
    @AppStorage("truncateList") var truncateList: Bool = false
    @AppStorage("listCount") var listCount: Int = 12
    @AppStorage("listView") var listView: Bool = false
    @AppStorage("folderView") var folderView: Bool = false
    
    // Markdown
    @AppStorage("markdownTheme") var markdownTheme: MarkdownTheme = .github
    
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("expensiveSearch") var expensiveSearch: Bool = false
    
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

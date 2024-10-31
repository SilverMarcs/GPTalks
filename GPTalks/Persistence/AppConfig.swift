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
    private init() {}
    
    // Appearance
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 18
    #endif
    
    #if os(macOS)
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .webview
    #else
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .native
    #endif
    
    #if os(macOS)
    @AppStorage("sidebarIconSize") var sidebarIconSize: SidebarIconSize = .system
    #else
    @AppStorage("sidebarIconSize") var sidebarIconSize: SidebarIconSize = .medium
    #endif
    
    #if os(macOS)
    @AppStorage("conversationListStyle") var conversationListStyle: ConversationListStyle = .list
    #else
    @AppStorage("conversationListStyle") var conversationListStyle: ConversationListStyle = .scrollview
    #endif
    
    @AppStorage("truncateList") var truncateList: Bool = false
    @AppStorage("listCount") var listCount: Int = 16
    
    // Markdown
    @AppStorage("markdownTheme") var markdownTheme: MarkdownTheme = .atom
    
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("expensiveSearch") var expensiveSearch: Bool = true
    @AppStorage("hideDock") var hideDock = false
    @AppStorage("onlyOneWindow") var onlyOneWindow = false
    @AppStorage("showStatusBar") var showStatusBar = false
    
    // Quick
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses extremeley concise."
    @AppStorage("quickMarkdownProvider") var quickMarkdownProvider: MarkdownProvider = .native
    
    func resetFontSize() {
        #if os(macOS)
        fontSize = 13
        #else
        fontSize = 18
        #endif
    }
}

enum SidebarIconSize: String, Codable, CaseIterable {
    case system
    case medium
    case large
}

enum ConversationListStyle: String, Codable, CaseIterable {
    case scrollview = "ScrollView"
    case list = "List"
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

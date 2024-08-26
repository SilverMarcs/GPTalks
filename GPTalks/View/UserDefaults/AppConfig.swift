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
    @AppStorage("hideDock") var hideDock = false
    
    // Quick
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses extremeley concise."
    
    // Misc
    @AppStorage("sidebarFocus") var sidebarFocus: Bool = false
    
    func resetFontSize() {
        #if os(macOS)
        fontSize = 13
        #else
        fontSize = 18
        #endif
    }
}


enum MarkdownProvider: String, Codable, CaseIterable {
    #if os(macOS)
    case webview
    #endif
    case native
    case disabled
    
    var name: String {
        switch self {
        #if os(macOS)
        case .webview: "WebView"
        #endif
        case .native: "Native"
        case .disabled: "Disabled"
        }
    }
}

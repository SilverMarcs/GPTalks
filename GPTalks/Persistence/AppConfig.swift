//
//  AppConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import SwiftMarkdownView

class AppConfig: ObservableObject {
    static let shared = AppConfig()
    private init() {}
    
    // Appearance
    @AppStorage("codeBlockTheme") var codeBlockTheme: CodeBlockTheme = .atom
    @AppStorage("renderSkeleton") var renderSkeleton: Bool = true
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 18
    #endif
    
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("enterToSend") var enterToSend: Bool = false
    @AppStorage("hideDock") var hideDock = false
    @AppStorage("onlyOneWindow") var onlyOneWindow = false
    
    // Quick
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses extremeley concise."
    
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

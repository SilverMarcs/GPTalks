//
//  Acknowledgement.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/11/2024.
//

import Foundation

struct Acknowledgement {
    let name: String
    let description: String
    let url: String
    
    static let acknowledgements = [
        Acknowledgement(name: "MacPaw/OpenAI", description: "Swift community driven package for OpenAI public API", url: "https://github.com/MacPaw/OpenAI"),
        Acknowledgement(name: "SwiftAnthropic", description: "An open-source Swift package for interacting with Anthropic's public API.", url: "https://github.com/jamesrochabrun/SwiftAnthropic"),
        Acknowledgement(name: "GoogleGenerativeAI", description: "The official Swift library for the Google Gemini API", url: "https://github.com/google-gemini/generative-ai-swift"),
        
        Acknowledgement(name: "markdown-webview", description: "A performant SwiftUI Markdown view", url: "https://github.com/tomdai/markdown-webview"),

//        Acknowledgement(name: "MarkdownView", description: "MarkdownView is a SwiftUI view that displays Markdown content.", url: "https://github.com/zunda-pixel/MarkdownView"),
//        Acknowledgement(name: "swift-markdown", description: "A Swift package for parsing, building, editing, and analyzing Markdown documents.", url: "https://github.com/swiftlang/swift-markdown"),
//        Acknowledgement(name: "swift-cmark", description: "CommonMark parsing and rendering library and program in C", url: "https://github.com/swiftlang/swift-cmark"),
//        Acknowledgement(name: "HighlightSwift", description: "Code syntax highlighting in Swift and SwiftUI", url: "https://github.com/appstefan/HighlightSwift"),
        
        Acknowledgement(name: "KeyboardShortcuts", description: "Add user-customizable global keyboard shortcuts (hotkeys) to your macOS app in minutes", url: "https://github.com/sindresorhus/KeyboardShortcuts")
    ]
}

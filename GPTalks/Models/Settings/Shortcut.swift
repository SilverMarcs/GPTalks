//
//  Shortcut.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

struct Shortcut: Identifiable {
    var id = UUID()
    let key: String
    let action: String
    
    static let chatNavigationShortcuts = [
        Shortcut(key: "⌘ + N", action: "New Chat"),
        Shortcut(key: "⌘ + ]", action: "Next Chat"),
        Shortcut(key: "⌘ + [", action: "Previous Chat"),
    ]
        
    static let chatInteractionShortcuts = [
        Shortcut(key: "⌘ + Return", action: "Send Prompt"),
        Shortcut(key: "⌘ + L", action: "Focus Inputbox"),
        Shortcut(key: "⌘ + R", action: "Regenerate Last Response"),
        Shortcut(key: "⌘ + E", action: "Edit Last Prompt"),
        Shortcut(key: "⌘ + K", action: "Rest Context"),
        Shortcut(key: "⌘ + D", action: "Delete Last Prompt/Response"),
    ]
        
    static let appSettingsShortcuts = [
        Shortcut(key: "⌘ + .", action: "Open Chat Config Menu"),
        Shortcut(key: "⌘ + ,", action: "Open App Settings"),
    ]
        
    static let fontSizeShortcuts = [
        Shortcut(key: "⌘  + +", action: "Increase Font Size"),
        Shortcut(key: "⌘  + -", action: "Decrease Font Size"),
        Shortcut(key: "⌘  + O", action: "Reset Font Size"),
    ]
}

//
//  Shortcut.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

struct Shortcut {
    let key: String
    let action: String
    
    static let shortcuts = [
        Shortcut(key: "⌘ + N", action: "New Chat"),
        Shortcut(key: "⌘ + Enter", action: "Send Prompt"),
        Shortcut(key: "⌘ + L", action: "Focus Inputbox"),
        Shortcut(key: "⌘ + R", action: "Regenerate Last Response"),
        Shortcut(key: "⌘ + E", action: "Edit Last Prompt"),
        Shortcut(key: "⌘ + D", action: "Delete Last Prompt/Response"),
        Shortcut(key: "⌘ + .", action: "Open Chat Config Menu"),
        Shortcut(key: "⌘ + ,", action: "Open App Settings"),
        Shortcut(key: "⌥ + Space", action: "Toggle Quick Panel"),
        Shortcut(key: "⌘  + +", action: "Increase Font Size"),
        Shortcut(key: "⌘  + -", action: "Decrease Font Size"),
        Shortcut(key: "⌘  + O", action: "Reset Font Size"),
    ]
}

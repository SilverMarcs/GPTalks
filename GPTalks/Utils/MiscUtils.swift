//
//  SwiftDataUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData
import GPTEncoder

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            url
        } else {
            "No SQLite database found."
        }
    }
}

// MARK: - Device Detection
func isIPadOS() -> Bool {
    #if os(macOS)
    return false
    #else
    return UIDevice.current.userInterfaceIdiom == .pad
    #endif
}


// MARK: - Token Counting
let sharedEncoder = GPTEncoder()
func countTokensFromText(_ text: String) -> Int {
    let encoded = sharedEncoder.encode(text: text)
    return encoded.count
}

// MARK: - Keyboard Shortcuts
#if os(macOS)
import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}
#endif

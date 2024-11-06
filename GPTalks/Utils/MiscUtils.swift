//
//  SwiftDataUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData

// MARK: - ModelContext
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

// MARK: - Keyboard Shortcuts
#if os(macOS)
import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}
#endif

// MARK: - Platform Color
#if os(macOS)
typealias PlatformColor = NSColor
#else
typealias PlatformColor = UIColor
#endif

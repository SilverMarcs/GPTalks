//
//  KeyboardShortcuts.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

#if os(macOS)
import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
    static let sendMessage = Self("sendMessage", default: .init(.return, modifiers: [.command]))
}
#endif

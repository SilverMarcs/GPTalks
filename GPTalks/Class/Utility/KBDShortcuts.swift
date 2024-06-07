//
//  KBDShortcuts.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/06/2024.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
    static let focusQuickPanel = Self("focusQuickPanel", default: .init(.l, modifiers: [.command]))
}

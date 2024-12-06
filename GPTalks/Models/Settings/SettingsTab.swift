//
//  SettingsTab.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

enum SettingsTab {
    case general
    case appearance
    #if os(macOS)
    case quickPanel
    case shortcuts
    #endif
    case tools
    case parameters
    case image
    case providers
    case advanced
    case guides
    case about
}

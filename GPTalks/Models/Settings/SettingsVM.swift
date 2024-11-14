//
//  SettingsVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

@Observable class SettingsVM {
    var listState: ListState = .chats
    
    #if os(macOS)
    var settingsTab: SettingsTab? = .general
    #else
    var settingsTab: SettingsTab?
    #endif
}

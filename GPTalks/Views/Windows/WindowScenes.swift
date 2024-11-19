//
//  WindowScenes.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/11/2024.
//

import SwiftUI
import SwiftData

struct WindowScenes: Scene {
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    var body: some Scene {
        Group {
            #if os(macOS)
            ChatWindow()
            ImageWindow()
            SettingsWindow()
            AboutWindow()
            HelpWindow()
            #else
            IOSWindow()
            #endif
        }
        .environment(\.providers, providers)
    }
}

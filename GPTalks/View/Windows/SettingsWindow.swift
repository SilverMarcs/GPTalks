//
//  SettingsWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI

#if os(macOS)
struct SettingsWindow: Scene {
    var body: some Scene {
        Window("Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 850, maxWidth: 850, minHeight: 600, maxHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .sidebar) {}
        }
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
    }
}
#endif

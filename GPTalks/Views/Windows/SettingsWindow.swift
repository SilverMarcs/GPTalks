//
//  SettingsWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

#if os(macOS)
import SwiftUI

struct SettingsWindow: Scene {
    var body: some Scene {
        Window("Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 850, maxWidth: 850, minHeight: 600, maxHeight: 600)
        }
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
    }
}
#endif

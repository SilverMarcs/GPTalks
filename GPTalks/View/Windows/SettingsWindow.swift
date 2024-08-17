//
//  SettingsWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI

struct SettingsWindow: Scene {
    var body: some Scene {
        Window("Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 820, maxWidth: 820, minHeight: 570, maxHeight: 570)
        }
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
    }
}

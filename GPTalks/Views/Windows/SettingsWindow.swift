//
//  SettingsWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI

struct SettingsWindow: Scene {
    var body: some Scene {
        Window("Settings", id: WindowID.settings) {
            SettingsView()
                .frame(minWidth: 850, maxWidth: 850, minHeight: 600, maxHeight: 600)
        }
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
    }
}

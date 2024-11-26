//
//  ShortcutSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutSettings: View {
    var body: some View {
        Form {
            LabeledContent {
                KeyboardShortcuts.Recorder(for: .togglePanel)
            } label: {
                Text("Quick Panel Shortcut")
            }
            
            Section("Chat Navigation") {
                ForEach(Shortcut.chatNavigationShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }

            Section("Chat Interaction") {
                ForEach(Shortcut.chatInteractionShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }

            Section("Application Settings") {
                ForEach(Shortcut.appSettingsShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }

            Section("Font Size Adjustment") {
                ForEach(Shortcut.fontSizeShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Keyboard Shortcuts")
        .toolbarTitleDisplayMode(.inline)
    }
}

struct ShortcutRow: View {
    var shortcut: Shortcut

    var body: some View {
        LabeledContent {
            Text(shortcut.action)
                .foregroundStyle(.primary)
        } label: {
            Text(shortcut.key)
                .monospaced()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ShortcutSettings()
}

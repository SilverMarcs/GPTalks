//
//  QuickPanelSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

import KeyboardShortcuts
import SwiftUI

#if os(macOS)
struct QuickPanelSettings: View {
    var body: some View {
        Form {
            Section("Launch") {
                HStack {
                    Text("Shortcut")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    QuickPanelSettings()
}
#endif

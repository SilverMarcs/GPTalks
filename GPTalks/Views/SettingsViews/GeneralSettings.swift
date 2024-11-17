//
//  GeneralSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import SwiftData

struct GeneralSettings: View {
    @ObservedObject var config = AppConfig.shared
    @Environment(\.modelContext) var modelContext

    var body: some View {
        Form {
            Section("Title") {
                Toggle(isOn: $config.autogenTitle) {
                    Text("Autogen Title")
                    Text("Uses Lite Model in provider general settings")
                }
            }
            
            #if os(macOS)
            Section("Windows") {
                Toggle(isOn: $config.onlyOneWindow) {
                    Text("Show one window at a time")
                    Text("If enabled, chat window will be closed when image window is opened and vice versa")
                }
                Toggle(isOn: $config.hideDock) {
                    Text("Hide icon in Dock")
                    Text("Dock icon reappears on app restart")
                }
                .onChange(of: config.hideDock) {
                    if config.hideDock {
                        NSApp.setActivationPolicy(.accessory)
                    } else {
                        NSApp.setActivationPolicy(.regular)
                    }
                }
            }
            #endif
            
            Section("Misc") {
                Toggle(isOn: $config.enterToSend) {
                    Text("Enter to send message")
                    Text("Enabling this makes input area laggy and is not recommended.")
                }
                
                LabeledContent("Restart Onboarding") {
                    Button("Launch") {
                        config.hasCompletedOnboarding = false
                    }
                }
            }
            
 
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GeneralSettings()
}

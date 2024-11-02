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
                    Text("Uses title model in provider general settings")
                }
            }
            
//            Section("Search") {
//                Toggle(isOn: $config.expensiveSearch) {
//                    Text("Expensive Search")
//                    Text("Search all messages but may cause UI responsiveness issues")
//                }
//            }
            
            #if os(macOS)
            Section("Windows") {
                Toggle(isOn: $config.onlyOneWindow) {
                    Text("Show one window at a time")
                    Text("If enabled, chat window will be closed when image window is opened and vice versa") 
                }
            }
            
            Section("Dock") {
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
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GeneralSettings()
}

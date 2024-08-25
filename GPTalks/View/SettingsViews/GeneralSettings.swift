//
//  GeneralSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct GeneralSettings: View {
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section {
                Toggle("Autogen Title", isOn: $config.autogenTitle)
            } header: {
                Text("Title")
            } footer: {
                SectionFooterView(text: "Uses Title model in provider general settings")
            }
            
            Section {
                Toggle("Expensive Search", isOn: $config.expensiveSearch)
            } header: {
                Text("Search")
            } footer: {
                SectionFooterView(text: "Expensive method searches all messages but may cause UI responsiveness issues")
            }
            
            #if os(macOS)
            Section {
                Toggle("Hide Dock Icon", isOn: $config.hideDock)
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

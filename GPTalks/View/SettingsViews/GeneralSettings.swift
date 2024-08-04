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
            Section("Markdown") {
                Picker("Markdown Provider", selection: $config.markdownProvider) {
                    ForEach(MarkdownProvider.allCases, id: \.self) { provider in
                        Text(provider.name)
                    }
                }
            }
            
            Section("Appearance") {
                Toggle("Compact List", isOn: $config.compactList)
            }
            
            Section("Behaviour") {
                Toggle("Autogen Title", isOn: $config.autogenTitle)
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

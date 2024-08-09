//
//  AppearanceSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI

struct AppearanceSettings: View {
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        Form {
            Section {
                Picker("Markdown Provider", selection: $config.markdownProvider) {
                    ForEach(MarkdownProvider.allCases, id: \.self) { provider in
                        Text(provider.name)
                    }
                }
            } header: {
                Text("Markdown")
            } footer: {
                SectionFooterView(text: "WebView is recommended on MacOS and Native on iOS.")
            }
            
            Section("Views") {
                Toggle("Compact List", isOn: $config.compactList)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AppearanceSettings()
}

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
            
            Section("List Row Count") {
                Toggle("Show Less Sessions", isOn: $config.truncateList)
                
                Stepper(value: $config.listCount, in: 6...20) {
                    HStack {
                        Text("List Count")
                        Spacer()
                        Text("\(config.listCount)")
                    }
                }
                .opacity(config.truncateList ? 1 : 0.5)
                .disabled(!config.truncateList)
            }
            
            Section("Views") {
                Toggle("Compact List Row", isOn: $config.compactList)
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

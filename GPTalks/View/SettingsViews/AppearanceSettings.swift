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
            Slider(value: $config.fontSize, in: 8...25, step: 1) {
                Text("Font Size: \(Int(config.fontSize))")
            } minimumValueLabel: {
                Text("8")
            } maximumValueLabel: {
                Text("25")
            }
            
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
            
            Section {
                Toggle("Compact List Row", isOn: $config.compactList)
                Toggle("List View", isOn: $config.listView)
                Toggle("Folder View", isOn: $config.folderView)
            } header: {
                Text("View Customisation")
            } footer: {
                SectionFooterView(text: "Scrolling within the view does not working in List View. Folder View is Experimental and extremely buggy")
            }
            
            Section {
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
            } header: {
                Text("List Row Count")
            } footer: {
                SectionFooterView(text: "Only applicable when not using folder view")
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

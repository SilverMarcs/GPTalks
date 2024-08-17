//
//  AppearanceSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI
import MarkdownWebView

struct AppearanceSettings: View {
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        Form {
            Slider(value: $config.fontSize, in: 8...25, step: 1) {
                HStack {
                    Text("Font Size: \(Int(config.fontSize))")
                    
                    Button("Reset") {
                        config.fontSize = 13
                    }
                }
            } minimumValueLabel: {
                Text("8")
            } maximumValueLabel: {
                Text("25")
            }
            
            Section {
                Toggle("Compact List Row", isOn: $config.compactList)
                Toggle("List View", isOn: $config.listView)
                Toggle("Folder View", isOn: $config.folderView)
            } header: {
                Text("View Customisation")
            } footer: {
                SectionFooterView(text: "Folder View is Experimental and extremely buggy")
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

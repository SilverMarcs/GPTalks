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
            Section("Font Size") {
                Slider(value: $config.fontSize, in: 8...25, step: 1) {
                    HStack {
                        Button("Reset") {
#if os(macOS)
                            config.fontSize = 13
#else
                            config.fontSize = 18
#endif
                        }
                    }
                } minimumValueLabel: {
                    Text("")
                        .monospacedDigit()
                } maximumValueLabel: {
                    Text(String(config.fontSize))
                        .monospacedDigit()
                }
            }
            
            Section {
                Toggle("Compact List Row", isOn: $config.compactList)
                #if os(macOS)
                Toggle("List View", isOn: $config.listView)
                #endif
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

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
                            config.resetFontSize()
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

            Section("View Customisation") {
                Toggle("Compact List Row", isOn: $config.compactList)
                
                #if os(macOS)
                VStack(alignment: .leading) {
                    Picker("ConversationList Style", selection: $config.conversationListStyle) {
                        ForEach(ConversationListStyle.allCases, id: \.self) { style in
                            Text(style.rawValue)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    
                    Text("ListView is smoother but some features may not function.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                #endif

                ToggleWithDescription(
                    title: "Folder View",
                    isOn: $config.folderView,
                    description: "Folder View is Experimental and extremely buggy"
                )
            }

            Section {
                Toggle("Show Less Sessions", isOn: $config.truncateList)

                HStack {
                    Stepper(
                        "List Count",
                        value: Binding<Double>(
                            get: { Double(config.listCount) },
                            set: { config.listCount = Int($0) }
                        ),
                        in: 6...20,
                        step: 1,
                        format: .number
                    )
                }
                .opacity(config.truncateList ? 1 : 0.5)
                .disabled(!config.truncateList)
            } header: {
                Text("List Row Count")
            } footer: {
                SectionFooterView(text: "Only applicable when NOT using folder view")
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


//
//  AppearanceSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI
import SwiftData
import SwiftMarkdownView

struct AppearanceSettings: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @State var session: Chat?

    var body: some View {
        Form {
            Section("Font Size") {
                HStack {
                    Button("Reset") {
                        config.resetFontSize()
                    }
                    
                    Slider(value: $config.fontSize, in: 8...25, step: 1) {
                        Text("")
                    } minimumValueLabel: {
                        Text("")
                            .monospacedDigit()
                    } maximumValueLabel: {
                        Text(String(config.fontSize))
                            .monospacedDigit()
                    }
                }
            }

            Section("Markdown") {
                Toggle("Skeleon Rendering in Markdown View", isOn: $config.renderSkeleton)
                
                Picker(selection: $config.markdownProvider) {
                    ForEach(MarkdownProvider.allCases) { provider in
                        Text(provider.name)
                            .tag(provider)
                    }
                } label: {
                    Text("Markdown Provider")
                    Text("Native uses less memeory but webview performs better")
                }
                #if os(macOS)
                .pickerStyle(.radioGroup)
                #endif
                
                if config.markdownProvider == .webview {
                    Picker(selection: $config.codeBlockTheme) {
                        ForEach(CodeBlockTheme.allCases, id: \.self) { theme in
                            Text(theme.name)
                        }
                    } label: {
                        Text("Code Block Theme")
                        Text("Change chat selection to take effect")
                    }
                    
                    MarkdownView(content: String.onlyCodeBlock)
                        .id(config.codeBlockTheme)
                        .padding(.bottom, -11)
                }
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


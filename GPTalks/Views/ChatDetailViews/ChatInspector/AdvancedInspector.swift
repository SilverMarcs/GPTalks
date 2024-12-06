//
//  AdvancedInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct AdvancedInspector: View {
    @Bindable var chat: Chat
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    var body: some View {
        Form {
            Section("Parameters") {
                MaxTokensPicker(value: $chat.config.maxTokens)
                TopPSlider(topP: $chat.config.topP, shortLabel: true)
                FrequencyPenaltySlider(penalty: $chat.config.frequencyPenalty, shortLabel: true)
                PresencePenaltySlider(penalty: $chat.config.presencePenalty, shortLabel: true)
            }
            
            
            if chat.config.provider.type == .anthropic {
                Section("Prompt Caching") {
                    Toggle(isOn: $chat.config.useCache) {
                        Text("Use Cache for new messages")
                        Text("Supports Anthropic Provider only.")
                    }
                }
            }
            
            Section("Tools") {
                ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
            }
            
            Button {
                isExportingMarkdown = true
            } label: {
                Label("Export Markdown", systemImage: "richtext.page")
            }
            .buttonStyle(ClickHighlightButton())
            .foregroundStyle(.accent)
            .fileExporter(
                isPresented: $isExportingMarkdown,
                document: MarkdownBackup(chat: chat),
                contentType: .plainText,
                defaultFilename: "\(chat.title).md"
            ) { result in
                switch result {
                case .success(let url):
                    print("Markdown saved to \(url)")
                case .failure(let error):
                    print("Error saving markdown: \(error)")
                }
            }
        }
        .formStyle(.grouped)
    }
}

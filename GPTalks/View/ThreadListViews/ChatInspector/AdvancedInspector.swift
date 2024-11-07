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
                TopPSlider(topP: $chat.config.topP, shortLabel: true)
                FrequencyPenaltySlider(penalty: $chat.config.frequencyPenalty, shortLabel: true)
                PresencePenaltySlider(penalty: $chat.config.presencePenalty, shortLabel: true)
            }
            
            Section("Tools") {
                ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
            }
            
            Section("Export") {
                Button {
                    isExportingJSON = true
                } label: {
                    Label("JSON", systemImage: "ellipsis.curlybraces")
                }
                .sessionExporter(isExporting: $isExportingJSON, sessions: [chat])
                .buttonStyle(ClickHighlightButton())
                .foregroundStyle(.accent)
                
                Button {
                    isExportingMarkdown = true
                } label: {
                    Label("Markdown", systemImage: "richtext.page")
                }
                .markdownSessionExporter(isExporting: $isExportingMarkdown, chat: chat)
                .buttonStyle(ClickHighlightButton())
                .foregroundStyle(.accent)
            }
        }
        .formStyle(.grouped)
    }
}

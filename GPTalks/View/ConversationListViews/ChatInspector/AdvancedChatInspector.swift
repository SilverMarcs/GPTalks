//
//  AdvancedChatInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct AdvancedChatInspector: View {
    @Bindable var session: ChatSession
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    var body: some View {
        Form {
            Section("Parameters") {
                TopPSlider(topP: $session.config.topP, shortLabel: true)
                FrequencyPenaltySlider(penalty: $session.config.frequencyPenalty, shortLabel: true)
                PresencePenaltySlider(penalty: $session.config.presencePenalty, shortLabel: true)
            }
            
            Section("Tools") {
                ToolsController(tools: $session.config.tools, isGoogle: session.config.provider.type == .google)
            }
            
            Section("Export") {
                Button {
                    isExportingJSON = true
                } label: {
                    Label("JSON", systemImage: "ellipsis.curlybraces")
                }
                .sessionExporter(isExporting: $isExportingJSON, sessions: [session])
                .buttonStyle(ClickHighlightButton())
                .foregroundStyle(.accent)
                
                Button {
                    isExportingMarkdown = true
                } label: {
                    Label("Markdown", systemImage: "richtext.page")
                }
                .markdownSessionExporter(isExporting: $isExportingMarkdown, session: session)
                .buttonStyle(ClickHighlightButton())
                .foregroundStyle(.accent)
            }
        }
        .formStyle(.grouped)
    }
}

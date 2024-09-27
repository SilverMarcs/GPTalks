//
//  ConversationStatusBar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ConversationStatusBar: View {
    @Bindable var session: ChatSession
    var providers: [Provider]
    
    var body: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 6, frame: 18, scale: .small)
            
            ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                session.config.model = provider.chatModel
            }
            .labelsHidden()
            .buttonStyle(.borderless)
            .fixedSize()
            
            ModelPicker(model: $session.config.model, models: session.config.provider.chatModels, label: "Model")
                .labelsHidden()
                .buttonStyle(.borderless)
                .fixedSize()
            
            HStack(spacing: 2) {
                Image(systemName: session.config.tools.enabledTools.isEmpty ? "hammer": "hammer.fill")
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(.teal)
                
                Menu {
                    ToolsController(tools: $session.config.tools)
                } label: {
                    Text("^[\(session.config.tools.enabledTools.count) Plugin](inflect: true)")
                }
                .menuStyle(SimpleIconOnly())
            }
            
            Spacer()
            
            // TODO: Add shortcuts educator popup here
        }
        .foregroundStyle(.secondary) // not working
        .opacity(0.8)
        .padding(.horizontal)
        .padding(.vertical, 7)
        .background(.background)
    }
}

//
//  ThreadStatusBar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ThreadStatusBar: View {
    @Environment(\.providers) var providers
    @Bindable var session: Chat
    
    var body: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 4, frame: 12, scale: .small)
                .padding(.leading, 6)
            
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
            
            Spacer()
            
            Label("Tools", systemImage: session.config.tools.enabledTools.isEmpty ? "hammer": "hammer.fill")
                .labelStyle(.titleOnly)
                .contentTransition(.symbolEffect(.replace))

            ControlGroup {
                ToolsController(tools: $session.config.tools, isGoogle: session.config.provider.type == .google)
            }
            .fixedSize()
        }
    }
}

struct SimpleIconOnly: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .menuStyle(BorderlessButtonMenuStyle())
            .fixedSize()
    }
}

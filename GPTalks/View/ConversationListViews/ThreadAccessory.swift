//
//  ThreadStatusBar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ThreadStatusBar: View {
    @Environment(\.providers) var providers
    @Bindable var chat: Chat
    
    var body: some View {
        HStack {
            ProviderImage(provider: chat.config.provider, radius: 4, frame: 12, scale: .small)
                .padding(.leading, 6)
            
            ProviderPicker(provider: $chat.config.provider, providers: providers) { provider in
                chat.config.model = provider.chatModel
            }
            .labelsHidden()
            .buttonStyle(.borderless)
            .fixedSize()
            
            ModelPicker(model: $chat.config.model, models: chat.config.provider.chatModels, label: "Model")
                .labelsHidden()
                .buttonStyle(.borderless)
                .fixedSize()
            
            Spacer()
            
            Label("Tools", systemImage: chat.config.tools.enabledTools.isEmpty ? "hammer": "hammer.fill")
                .labelStyle(.titleOnly)
                .contentTransition(.symbolEffect(.replace))

            ControlGroup {
                ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
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

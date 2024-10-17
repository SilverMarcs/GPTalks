//
//  ConversationStatusBar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI
import SwiftData

struct ConversationStatusBar: View {
    @Bindable var session: ChatSession
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var body: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 5, frame: 14, scale: .small)
            
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
                ForEach(Array(session.config.tools.toolStates.keys), id: \.self) { tool in
                    Toggle(isOn: Binding(
                        get: { session.config.tools.isToolEnabled(tool) },
                        set: { newValue in
                            session.config.tools.setTool(tool, enabled: newValue)
                        }
                    )) {
                        Label(tool.displayName, systemImage: tool.icon)
                    }
                }
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

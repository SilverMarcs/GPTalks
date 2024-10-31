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
//                if session.config.provider.type == .google {
//                    Toggle(isOn: Binding(
//                        get: { session.config.tools.googleCodeExecution },
//                        set: { newValue in
//                            session.config.tools.setGoogleCodeExecution(newValue)
//                        }
//                    )) {
//                        Label("Code Execution", systemImage: "curlybraces")
//                    }
//                    .popoverTip(GoogleCodeExecutionTip())
//                }

                ToolsController(tools: $session.config.tools, showGoogleCodeExecution: session.config.provider.type == .google)
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

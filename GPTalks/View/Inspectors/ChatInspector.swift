//
//  ChatInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import SwiftData

struct ChatInspector: View {
    @Bindable var session: Session
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)], animation: .default)
    var providers: [Provider]
    @State var expandAdvanced: Bool = false
    
    var body: some View {
        Form {
            Section("Title") {
                HStack(spacing: 0) {
                    title
                    Spacer()
                    generateTitle
                }

            }
            
            Section("Models") {
                ProviderPicker(
                    provider: $session.config.provider,
                    providers: providers,
                    onChange: { newProvider in
                        session.config.model = newProvider.chatModel
                    }
                )
                ModelPicker(model: $session.config.model, models: session.config.provider.chatModels, label: "Model")
            }
            
            Section("Basic") {
                Toggle("Stream", isOn: $session.config.stream)
                TemperatureSlider(temperature: $session.config.temperature, shortLabel: true)
                MaxTokensPicker(value: $session.config.maxTokens)
            }
            
            Section("System Prompt") {
                sysPrompt
            }
            
            #if os(macOS)
            Section("Advanced", isExpanded: $expandAdvanced) {
                TopPSlider(topP: $session.config.topP, shortLabel: true)
                FrequencyPenaltySlider(penalty: $session.config.frequencyPenalty, shortLabel: true)
                PresencePenaltySlider(penalty: $session.config.presencePenalty, shortLabel: true)
            }
            #endif
            
            Section("") {
                resetContext
                deleteAllMessages
            }
            .buttonStyle(.plain)
        }
        .formStyle(.grouped)
    }
    
    private var title: some View {
        TextField("Title", text: $session.title)
            .lineLimit(1)
            .labelsHidden()
    }
    
    private var sysPrompt: some View {
        TextField("System Prompt", text: $session.config.systemPrompt, axis: .vertical)
            .lineLimit(5, reservesSpace: true)
            .labelsHidden()
    }
    
    private var generateTitle: some View {
        Button {
            if session.isStreaming { return }
            Task { await session.generateTitle(forced: true) }
        } label: {
            Image(systemName: "sparkles")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.mint)
    }
    
    private var resetContext: some View {
        Button {
            if session.isStreaming { return }
            if let lastGroup = session.groups.last {
                session.resetContext(at: lastGroup)
            }
        } label: {
            Text("Reset Context")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .foregroundStyle(.orange)
    }
    
    private var deleteAllMessages: some View {
        Button(role: .destructive) {
            if session.isStreaming { return }
            
            session.deleteAllConversations()
        } label: {
            Text("Delete All Messages")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .foregroundStyle(.red)
    }
}

#Preview {
    ChatInspector(session: Session(config: SessionConfig()))
        .modelContainer(for: Provider.self, inMemory: true)
        .formStyle(.grouped)
        .frame(width: 300, height: 700)
}

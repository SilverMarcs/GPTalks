//
//  BasicChatInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct BasicChatInspector: View {
    @Bindable var session: Session
    var providers: [Provider]
    
    @State var isGeneratingTtile: Bool = false
    
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
            
            deleteAllMessages
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
            isGeneratingTtile.toggle()
            Task {
                await session.generateTitle(forced: true)
                isGeneratingTtile.toggle()
            }
        } label: {
            Image(systemName: "sparkles")
                .symbolEffect(.pulse, isActive: isGeneratingTtile)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.mint.gradient)
        .popoverTip(GenerateTitleTip())
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

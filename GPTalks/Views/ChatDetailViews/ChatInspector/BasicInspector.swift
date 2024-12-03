//
//  BasicInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import SwiftData

struct BasicInspector: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var chat: Chat
    
    @State var isGeneratingTtile: Bool = false
    @State var showingDeleteConfirmation: Bool = false
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
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
                    provider: $chat.config.provider,
                    providers: providers,
                    onChange: { newProvider in
                        chat.config.model = newProvider.chatModel
                    }
                )
                
                ModelPicker(model: $chat.config.model, models: chat.config.provider.chatModels, label: "Model")
            }
            
            Section("Parameters") {
                Toggle(isOn: $chat.config.stream) {
                    Text("Stream")
                    Text("This feature is temporarily disabled.")
                }
                .disabled(true)
                
                TemperatureSlider(temperature: $chat.config.temperature, shortLabel: true)
            }
            
            Section("System Prompt") {
                sysPrompt
            }
            
            Section {
                resetContext
                deleteAllMessages
            }

        }
        .formStyle(.grouped)
    }
    
    private var title: some View {
        TextField("Title", text: $chat.title)
            .lineLimit(1)
            .labelsHidden()
    }
    
    private var sysPrompt: some View {
        TextField("System Prompt", text: $chat.config.systemPrompt, axis: .vertical)
            #if os(macOS)
            .lineLimit(6, reservesSpace: true)
            #else
            .lineLimit(5, reservesSpace: true)
            #endif
            .labelsHidden()
    }
    
    private var generateTitle: some View {
        Button {
            if chat.isReplying { return }
            isGeneratingTtile.toggle()
            Task {
                await chat.generateTitle(forced: true)
                isGeneratingTtile.toggle()
            }
        } label: {
            Image(systemName: "sparkles")
                .symbolEffect(.pulse, isActive: isGeneratingTtile)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.mint.gradient)
    }
    
    private var resetContext: some View {
        Button(action: {}) {
            Button {
                guard !chat.isReplying, let lastMessage = chat.currentThread.last else { return }
                chat.resetContext(at: lastMessage)
                dismiss()
            } label: {
                Text("Reset Context At Last Message")
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.orange)
            #if os(macOS)
            .buttonStyle(ClickHighlightButton())
            #else
            .buttonStyle(.bordered)
            #endif
        }
        .buttonStyle(.plain)
        .listRowBackground(EmptyView())
        .listRowInsets(EdgeInsets())
    }
    
    private var deleteAllMessages: some View {
        Button(action: {}) {
            Button(role: .destructive) {
                if chat.isReplying { return }
                
                showingDeleteConfirmation.toggle()
            } label: {
                Text("Delete All Messages")
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.red)
            #if os(macOS)
            .buttonStyle(ClickHighlightButton())
            #else
            .buttonStyle(.bordered)
            #endif
        }
        .buttonStyle(.plain)
        .listRowBackground(EmptyView())
        .listRowInsets(EdgeInsets())
        .confirmationDialog("Are you sure you want to delete all messages?", isPresented: $showingDeleteConfirmation) {
            Button("Delete All", role: .destructive) {
                chat.deleteAllMessages()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

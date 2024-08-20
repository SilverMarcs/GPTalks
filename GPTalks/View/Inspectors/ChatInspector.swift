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
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    @State var expandAdvanced: Bool = false
    @State var isGeneratingTtile: Bool = false
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            #if os(macOS)
            HStack {
                export
                
                Spacer()
                DismissButton() {
                    dismiss()
                }
                .imageScale(.large)
                .buttonStyle(.plain)
            }
            .padding([.top, .horizontal])
            #endif
            
            Form {
                Section("Title") {
                    HStack(spacing: 0) {
                        title
                        Spacer()
                        generateTitle
                    }
                    
                }
                .sessionExporter(isExporting: $isExportingJSON, sessions: [session])
                
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
                .markdownSessionExporter(isExporting: $isExportingMarkdown, session: session)
                
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
        #if !os(macOS)
        .navigationTitle("Tokens: " + String(session.tokenCount))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                DismissButton()
                    .buttonStyle(.plain)
            }
        }
        #endif
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
    
    private var export: some View {
        Menu {
            Button {
                isExportingJSON = true
            } label: {
                Label("JSON", systemImage: "ellipsis.curlybraces")
            }
            
            Button {
                isExportingMarkdown = true
            } label: {
                Label("Markdown", systemImage: "richtext.page")
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .fixedSize()
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .foregroundStyle(.link)
    }
}

#Preview {
    ChatInspector(session: Session(config: SessionConfig()))
        .modelContainer(for: Provider.self, inMemory: true)
        .formStyle(.grouped)
        .frame(width: 300, height: 700)
}

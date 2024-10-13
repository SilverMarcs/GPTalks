//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationListToolbar: CustomizableToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ChatSessionVM.self) private var sessionVM
    @Bindable var session: ChatSession
    
    @State var showingInspector: Bool = false
    @State var showingShortcuts = false

    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var body: some CustomizableToolbarContent {
        ToolbarItem(id: "chat-inspector-toggle", placement: horizontalSizeClass == .compact ? .primaryAction : .navigation) {
            Button {
                toggleInspector()
            } label: {
                Label("Shortcuts", systemImage: horizontalSizeClass == .compact ? "info.circle" : "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(session: session)
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        .customizationBehavior(.disabled)
        
        if !(horizontalSizeClass == .compact) {
            ToolbarItem(id: "provider-picker") {
                ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                    session.config.model = provider.chatModel
                }
            }
            .defaultCustomization(.visible)
            
            ToolbarItem(id: "model-picker") {
                ModelPicker(model: $session.config.model, models: session.config.provider.chatModels, label: "Model")
            }
            .defaultCustomization(.visible)
            
            ToolbarItem(id: "temp-slider") {
                TemperatureSlider(temperature: $session.config.temperature)
                    .frame(width: 100)
            }
            .defaultCustomization(.hidden)
            
            ToolbarItem(id: "stream-control") {
                Toggle("Stream", isOn: $session.config.stream)
            }
            .defaultCustomization(.hidden)
            
            ToolbarItem(id: "tools-controls") {
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
            }
            .defaultCustomization(.hidden)
            
            ToolbarItem(id: "max-tokens-picker") {
                MaxTokensPicker(value: $session.config.maxTokens)
            }
            .defaultCustomization(.hidden)
        }
        
        #if os(macOS)
        ToolbarItem(id: "shortcuts-popover", placement: .primaryAction) {
            Button {
                showingShortcuts.toggle()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
            .popover(isPresented: $showingShortcuts) {
                ConversationShortcuts()
            }
        }
        .defaultCustomization(.visible)
        #endif
    }
    
    private func toggleInspector() {
        #if !os(macOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        showingInspector.toggle()
    }
}

#Preview {
    VStack {
        Text("Hello, World!")
    }
    .frame(width: 700, height: 300)
    .toolbar {
        ConversationListToolbar(session: .mockChatSession)
    }
}

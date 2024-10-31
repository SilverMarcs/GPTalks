//
//  QuickPanel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI
import SwiftData

#if os(macOS)
struct QuickPanel: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @Bindable var session: ChatSession
    @Binding var isPresented: Bool
    @Binding var showAdditionalContent: Bool
    
    @FocusState private var isFocused: Bool
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    @State var selections: Set<ChatSession> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            textfieldView
                .padding(15)
                .padding(.leading, 1)
                .frame(height: 57)
            
            if !session.inputManager.dataFiles.isEmpty {
                DataFileView(dataFiles: $session.inputManager.dataFiles, isCrossable: true)
                    .safeAreaPadding(.horizontal)
                    .safeAreaPadding(.vertical, 10)
            }
            
            if session.groups.isEmpty {
                Spacer()
            } else {
                Divider()
                
                ConversationList(session: session)
                    .scrollContentBackground(.hidden)
                
                bottomView
            }
        }
        .frame(width: 650)
        .onChange(of: isPresented) {
            if isPresented {
            
                selections = sessionVM.chatSelections
                sessionVM.chatSelections = [self.session]
                isFocused = true
                if !session.groups.isEmpty {
                    showAdditionalContent = true
                }
            } else {
                DispatchQueue.main.async {
                    sessionVM.chatSelections = selections
                }
            }
        }
        .onChange(of: isFocused) {
            isFocused = true
        }
        .onChange(of: session.inputManager.dataFiles.isEmpty) {
            if session.inputManager.dataFiles.isEmpty {
                showAdditionalContent = false
            } else {
                showAdditionalContent = true
            }
        }
    }
    
    @ViewBuilder
    var textfieldView: some View {
        HStack(spacing: 12) {
            Menu {
                ProviderPicker(
                    provider: $session.config.provider,
                    providers: providers,
                    onChange: { newProvider in
                        session.config.model = newProvider.quickChatModel
                    }
                )

                ModelPicker(model: $session.config.model, models: session.config.provider.chatModels, label: "Model")
                
                Menu {
                    ToolsController(tools: $session.config.tools)
                } label: {
                    Label("Tools", systemImage: "hammer")
                }
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            TextField("Ask Anything...", text: $session.inputManager.prompt, axis: .vertical)
                .focused($isFocused)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
                .allowsHitTesting(false)
            
            if session.isReplying {
                StopButton(size: 28) {
                    session.stopStreaming()
                }
            } else {
                SendButton(size: 28) {
                    send()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
    
    private var bottomView: some View {
        HStack {
            Group {
                Button {
                    resetChat()
                } label: {
                    Image(systemName: "delete.left")
                        .imageScale(.medium)
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
                
                Group {
                    Text(session.config.provider.name.uppercased())
                    
                    Text(session.config.model.name)
                    
                    ForEach(session.config.tools.enabledTools) { tool in
                        Image(systemName: tool.icon)
                    }
                }
                .font(.caption)
                
                Spacer()
                
                Button {
                    addToDB()
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .imageScale(.medium)
                }
                .disabled(session.groups.isEmpty)
                .keyboardShortcut("N", modifiers: [.command])
                
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(7)
        }
        .background(.regularMaterial)
    }
    
    private func resetChat() {
        showAdditionalContent = false
        session.deleteAllConversations()
        session.inputManager.dataFiles.removeAll()
        let oldConfig = session.config

        let fetchDefaults = FetchDescriptor<ProviderDefaults>()
        let defaults = try! modelContext.fetch(fetchDefaults)
        
        let quickProvider = defaults.first!.quickProvider
        session.config = .init(provider: quickProvider, purpose: .quick)
        
        modelContext.delete(oldConfig)
    }
    
    private func addToDB() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        
        Task {
            let newSession = await session.copy(purpose: .quick)
            sessionVM.fork(newSession: newSession)
            resetChat()
            
            showAdditionalContent = false
            isPresented = false
            
            if let mainWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "chats" }) {
                mainWindow.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func send() {
        if session.inputManager.prompt.isEmpty {
            return
        }
        
        session.config.systemPrompt = AppConfig.shared.quickSystemPrompt
        
        Task {
            await session.sendInput(forQuick: true)
        }
        
        showAdditionalContent = true
    }
}

#Preview {
    let quickSesion = ChatSession.mockChatSession
    quickSesion.isQuick = true
    
    return QuickPanel(session: quickSesion, isPresented: .constant(true), showAdditionalContent: .constant(true))
}
#endif

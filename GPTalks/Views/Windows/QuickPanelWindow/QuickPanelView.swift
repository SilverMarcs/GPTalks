//
//  QuickPanelView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI
import SwiftData

#if os(macOS)
struct QuickPanelView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ChatVM.self) private var chatVM
    @Environment(SettingsVM.self) private var settingsVM
    
    @Bindable var chat: Chat

    @FocusState private var isFocused: Bool
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    @State var selections: Set<Chat> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            textfieldView
                .padding(15)
                .padding(.leading, 1)
                .frame(height: 57)
            
            if !chat.inputManager.dataFiles.isEmpty {
                DataFilesView(dataFiles: chat.inputManager.dataFiles) { file in
                    chat.inputManager.dataFiles.removeAll { $0 == file }
                }
                .safeAreaPadding(.horizontal)
                .safeAreaPadding(.vertical, 10)
            }
            
            if chat.threads.isEmpty {
                Spacer()
            } else {
                Divider()
                
                ChatDetail(chat: chat)
                    .scrollContentBackground(.hidden)
                
                bottomView
            }
        }
        .frame(width: 650)
        .onChange(of: settingsVM.isQuickPanelPresented) {
            if settingsVM.isQuickPanelPresented {
            
                selections = chatVM.selections
                chatVM.selections = [self.chat]
                isFocused = true
                if !chat.threads.isEmpty {
                    settingsVM.isQuickPanelExpanded = true
                }
            } else {
                DispatchQueue.main.async {
                    chatVM.selections = selections
                }
            }
        }
        .onChange(of: isFocused) {
            isFocused = true
        }
        .onChange(of: chat.inputManager.dataFiles.isEmpty) {
            if chat.inputManager.dataFiles.isEmpty {
                settingsVM.isQuickPanelExpanded = false
            } else {
                settingsVM.isQuickPanelExpanded = true
            }
        }
    }
    
    @ViewBuilder
    var textfieldView: some View {
        HStack(spacing: 12) {
            Menu {
                ProviderPicker(
                    provider: $chat.config.provider,
                    providers: providers,
                    onChange: { newProvider in
                        chat.config.model = newProvider.liteModel
                    }
                )

                ModelPicker(model: $chat.config.model, models: chat.config.provider.chatModels, label: "Model")
                
                Menu {
                    ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
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
            
            TextField("Ask Anything...", text: $chat.inputManager.prompt, axis: .vertical)
                .focused($isFocused)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
                .allowsHitTesting(false)
                .onSubmit {
                    send()
                }
            
            Button(action: chat.isReplying ? chat.stopStreaming : send) {
                Image(systemName: chat.isReplying ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.largeTitle).fontWeight(.semibold)
            }
            .foregroundStyle((chat.isReplying ? AnyShapeStyle(.background) : AnyShapeStyle(.white)), (chat.isReplying ? .red : .accent))
            .buttonStyle(.plain)
            .contentTransition(.symbolEffect(.replace, options: .speed(2)))
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
                    Text(chat.config.provider.name.uppercased())
                    
                    Text(chat.config.model.name)
                    
                    ForEach(chat.config.tools.enabledTools) { tool in
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
                .disabled(chat.threads.isEmpty)
                .keyboardShortcut("N", modifiers: [.command])
                
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(7)
        }
        .background(.regularMaterial)
    }
    
    private func resetChat() {
        settingsVM.isQuickPanelExpanded = false
        chat.deleteAllThreads()
        chat.inputManager.dataFiles.removeAll()
        let oldConfig = chat.config

        let fetchDefaults = FetchDescriptor<ProviderDefaults>()
        let defaults = try! modelContext.fetch(fetchDefaults)
        
        let quickProvider = defaults.first!.quickProvider
        chat.config = .init(provider: quickProvider, purpose: .quick)
        
        modelContext.delete(oldConfig)
    }
    
    private func addToDB() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        
        Task {
            let newChat = await chat.copy(purpose: .chat)
            chatVM.fork(newChat: newChat)
            resetChat()
            
            settingsVM.isQuickPanelExpanded = false
            settingsVM.isQuickPanelPresented = false
            
            if let mainWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "chats" }) {
                mainWindow.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func send() {
        if chat.inputManager.prompt.isEmpty {
            return
        }
        
        chat.config.systemPrompt = AppConfig.shared.quickSystemPrompt
        
        Task {
            await chat.sendInput()
        }
        
        settingsVM.isQuickPanelExpanded = true
    }
}

#Preview {
    QuickPanelView(chat: .mockChat)
}
#endif

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
    @Environment(SessionVM.self) private var sessionVM
    
    @Bindable var session: Session
    @Binding var showAdditionalContent: Bool
    @State var prompt: String = ""
    @FocusState private var isFocused: Bool
    let dismiss: () -> Void
    
    @Query var providers: [Provider]
    @Query var sessions: [Session]
    
    var body: some View {
        VStack(spacing: 0) {
            textfieldView
                .padding(15)
                .padding(.leading, 2)
            
            if showAdditionalContent {
                Divider()
                
                ConversationList(session: session, isQuick: true)
                
                bottomView
            }
        }
        .frame(width: 650)
        .onAppear {
            resetChat()
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
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            TextField("Ask Anything...", text: $prompt)
                .focused($isFocused)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
            
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
    
    private var conversationView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(session.groups) { group in
                        ConversationGroupView(group: group)
                    }
                }
                .onChange(of: session.groups.count) {
                    withAnimation {
                        proxy.scrollTo(session.groups.last, anchor: .bottom)
                    }
                }
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
                .keyboardShortcut(.delete, modifiers: [.command])
                
                Group {
                    Text(session.config.provider.name.uppercased())
                    
                    Text(session.config.model.name)
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
        if let quickProvider = ProviderManager.shared.getQuickProvider(providers: providers) {
            session.config = .init(provider: quickProvider, purpose: .quick)
        }
    }
    
    private func addToDB() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        
        let newSession = session.copy(title: "Quick Session")
        sessionVM.fork(session: newSession, sessions: sessions, modelContext: modelContext)
        resetChat()
        
        showAdditionalContent = false
        dismiss()
    }
    
    private func send() {
        if prompt.isEmpty {
            return
        }
        
        showAdditionalContent = true
        
        session.inputManager.prompt = prompt
        
        Task { @MainActor in
            await session.sendInput()
        }
        
        prompt = ""
    }
}

#Preview {
    let showAdditionalContent = Binding.constant(true)
    let dismiss = {}
    
    QuickPanel(session: Session(config: .init()), showAdditionalContent: showAdditionalContent, dismiss: dismiss)
}
#endif

//
//  PanelTextEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/05/2024.
//

import SwiftUI
import KeyboardShortcuts

#if os(macOS)
struct PanelTextEditor: View {
    @Environment(DialogueViewModel.self) private var viewModel
    @State var prompt: String = ""
    @Binding var showAdditionalContent: Bool
    
    @State var session: DialogueSession = DialogueSession(configuration: .init(quick: true))
    
    @FocusState private var isFocused: Bool
    
    let dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            textfieldView
                .padding(15)
                .padding(.leading, 2)
            
            if showAdditionalContent {
                Divider()
                
                conversationView
                
                bottomView
            }
        }
        .task {
            KeyboardShortcuts.onKeyDown(for: .focusQuickPanel) {
                isFocused = true
            }
        }
    }
    
    private var textfieldView: some View {
        HStack(spacing: 12) {
            Menu {
                ProviderPicker(session: session)
                ModelPicker(session: session)
                ToolToggle(session: session)
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            TextField("Ask AI...", text: $prompt)
                .focused($isFocused)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
                
            Group {
                if session.isReplying {
                    StopButton(size: 28) {
                        Task { @MainActor in
                            session.stopStreaming()
                        }
                     }
                } else {
                    SendButton2(size: 28) {
                        send()
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var conversationView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(session.conversations) { conversation in
                        ConversationView(session: session, conversation: conversation, isQuick: true)
                            .id(conversation.id.uuidString)
                    }
                }
                .onChange(of: session.conversations) {
                    withAnimation {
                        proxy.scrollTo(session.conversations.last?.id.uuidString, anchor: .bottom)
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
                
                
                Spacer()
                
                Button {
                    addToDB()
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .imageScale(.medium)
                }
                .keyboardShortcut("N", modifiers: [.command])

            }
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
            .padding(7)
        }
        .background(.regularMaterial)
    }
    
    private func resetChat() {
        showAdditionalContent = false
        session.removeAllConversations()
        session.configuration = .init(quick: true)
    }
    
    private func addToDB() {
        if session.conversations.isEmpty || session.isReplying {
            return
        }
        
        dismiss()

        viewModel.addDialogue(conversations: session.conversations)
        
        NSApp.activate(ignoringOtherApps: true)
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        
        session.removeAllConversations()
        showAdditionalContent = false
    }
    
    private func send() {
        if prompt.isEmpty {
            return
        }
        
        showAdditionalContent = true
        
        session.input = prompt

        Task { @MainActor in
            await session.send()
        }
        
        prompt = ""
    }
}

#endif

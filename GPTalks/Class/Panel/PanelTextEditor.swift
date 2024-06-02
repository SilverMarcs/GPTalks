//
//  PanelTextEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/05/2024.
//

import SwiftUI

#if os(macOS)
struct PanelTextEditor: View {
    @Environment(DialogueViewModel.self) private var viewModel
    @State var prompt: String = ""
    @Binding var showAdditionalContent: Bool
    
    @State var session: DialogueSession = DialogueSession()
    
    @FocusState private var isFocused: Bool
    
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Button {
                    #if DEBUG
                    showAdditionalContent.toggle()
                    #endif
                    isFocused = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("L", modifiers: [.command])
                
                TextField("Ask AI...", text: $prompt)
                    .focused($isFocused)
                    .font(.system(size: 25))
                    .textFieldStyle(.plain)
                    
                Group {
                    if session.isReplying {
                        StopButton(size: 28) {
                            session.stopStreaming()
                        }
                    } else {
                        SendButton2(size: 28) {
                            send()
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
            .padding(.leading, 3)
            .padding(.bottom, -9)
            
            if showAdditionalContent {
                Divider()
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(session.conversations) { conversation in
                            ConversationView(session: session, conversation: conversation, isQuick: true)
                        }
                    }
                }
                
                HStack {
                    Group {
                        Button {
                            showAdditionalContent = false
                            session.removeAllConversations()
                        } label: {
                            Image(systemName: "delete.left")
                                .imageScale(.medium)
                        }
                        
                        
                        Spacer()
                        
                        Button {
                            addToDB()
                        } label: {
                            Image(systemName: "plus.square.on.square")
                                .imageScale(.medium)
                        }

                    }
                    .foregroundColor(.secondary)
                    .buttonStyle(.plain)
                    .padding(7)
                }
                .background(.ultraThickMaterial)
            }
        }
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
        
        session.configuration = DialogueSession.Configuration(quick: true)
        session.input = prompt

        Task { @MainActor in
            await session.send()
        }
        
        prompt = ""
    }
}

#endif

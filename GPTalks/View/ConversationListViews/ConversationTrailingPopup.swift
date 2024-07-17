//
//  ConversationTrailingPopup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ConversationTrailingPopup: View {
    @Bindable var session: Session
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {
            Section("Title") {
                title
                    .font(.body)
                    .focused($isFocused)
                    .onAppear {
                        DispatchQueue.main.async {
                            isFocused = false
                        }
                    }
                    .onChange(of: session.title) {
                        session.title = String(
                            session.title.trimmingCharacters(
                                in: .newlines))
                    }
            }

            Section("System Prompt") {
                sysPrompt
                    .font(.body)
                    .onChange(of: session.config.systemPrompt) {
                        session.config.systemPrompt = String(
                            session.config.systemPrompt.trimmingCharacters(
                                in: .newlines))
                    }
            }
        }
        .textEditorStyle(.plain)
        .formStyle(.grouped)
        #if os(macOS)
            .frame(width: 400, height: 250)
        #endif
    }
    
    private var title: some View {
        #if os(macOS)
        TextEditor(text: $session.title)
        #else
        TextField("Title", text: $session.title)
            .lineLimit(1)
        #endif
    }
    
    private var sysPrompt: some View {
        #if os(macOS)
        TextEditor(text: $session.config.systemPrompt)
        #else
        TextField("System Prompt", text: $session.config.systemPrompt, axis: .vertical)
            .lineLimit(5, reservesSpace: true)
        #endif
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    ConversationTrailingPopup(session: session)
        .padding()
}

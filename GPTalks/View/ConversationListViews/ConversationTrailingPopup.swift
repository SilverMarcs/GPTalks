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
                TextEditor(text: $session.title)
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
                TextEditor(text: $session.config.systemPrompt)
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
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    ConversationTrailingPopup(session: session)
        .padding()
}

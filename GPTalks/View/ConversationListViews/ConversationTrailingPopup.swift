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
        VStack(alignment: .leading) {
            GroupBox("Title") {

                TextField("Title", text: $session.title)
                    .focused($isFocused)
                    .onAppear {
                        DispatchQueue.main.async {
                            isFocused = false
                        }
                    }
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 3)
                    .frame(width: 300)
            }

            GroupBox("System Prompt") {
                TextField(
                    "System Prompt", text: $session.config.systemPrompt,
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .padding(.horizontal, 3)
                .frame(width: 300)
                .lineLimit(7, reservesSpace: true)
            }
        }
        .padding(13)
    }
}

#Preview {
    let session = Session()
    ConversationTrailingPopup(session: session)
        .padding()
}

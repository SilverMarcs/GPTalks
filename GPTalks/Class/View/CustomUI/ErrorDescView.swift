//
//  ErrorDescView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/12/2023.
//

import SwiftUI

struct ErrorDescView: View {
    var session: DialogueSession

    var body: some View {
        if session.errorDesc != "" && !session.conversations.isEmpty {
            VStack(spacing: 15) {
                HStack {
                    Text(session.errorDesc)
                        .textSelection(.enabled)
                        .foregroundStyle(.red)
                    
                    Button(role: .destructive) {
                        withAnimation {
                            session.resetErrorDesc()
                        }
                    } label: {
                        Image(systemName: "delete.backward")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
                Button("Retry") {
                    Task { @MainActor in
                        await session.retry()
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
                .clipShape(.capsule(style: .circular))
            }
            .padding()
        } else {
            EmptyView()
        }
    }
}

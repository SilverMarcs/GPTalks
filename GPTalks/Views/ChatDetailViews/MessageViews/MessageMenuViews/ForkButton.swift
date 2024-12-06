//
//  ForkButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct ForkButton: View {
    var copyChat: () async -> Chat?

    @Environment(ChatVM.self) var chatVM
    @State private var isForking = false

    var body: some View {
        if isForking {
            ProgressView()
                .controlSize(.small)
        } else {
            Button {
                isForking = true
                Task {
                    if let newChat = await copyChat() {
                        chatVM.fork(newChat: newChat)
                        isForking = false
                    }
                }
            } label: {
                Label("Fork Chat", systemImage: "arrow.branch")
            }
            .help("Fork Chat")
        }
    }
}

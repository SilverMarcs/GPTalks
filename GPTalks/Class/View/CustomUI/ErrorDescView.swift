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
        VStack(spacing: 15) {
            Text(session.errorDesc)
                .textSelection(.enabled)
                .foregroundStyle(.red)
            Button("Retry") {
                Task { @MainActor in
                    await session.retry()
                }
            }
            .keyboardShortcut("r", modifiers: .command)
            .clipShape(.capsule(style: .circular))
        }
    }
}

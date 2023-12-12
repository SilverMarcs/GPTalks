//
//  ErrorDescView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/12/2023.
//

import SwiftUI

struct ErrorDescView: View {
    @ObservedObject var session: DialogueSession
    
    var body: some View {
        VStack(spacing: 15) {
            Text(session.errorDesc)
                .foregroundStyle(.red)
            Button("Retry") {
                Task { @MainActor in
                    await session.retry()
                }
            }
            .clipShape(.capsule(style: .circular))
        }
    }
}

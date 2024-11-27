//
//  RegenButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct RegenButton: View {
    var message: MessageGroup
    
    var body: some View {
        if !message.isSplitView {
            Button {
                Task {
                    await message.chat?.regenerate(message: message)
                }
            } label: {
                Label("Regenerate", systemImage: "arrow.2.circlepath")
            }
        }
    }
}

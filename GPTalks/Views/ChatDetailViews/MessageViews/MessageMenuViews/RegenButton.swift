//
//  RegenButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct RegenButton: View {
    @Environment(\.providers) var providers
    
    var message: MessageGroup
    
    var body: some View {
        #if os(macOS)
        Menu {
            ForEach(providers) { provider in
                Menu {
                    ForEach(provider.chatModels) { model in
                        Button(model.name) {
                            message.chat?.config.provider = provider
                            message.chat?.config.model = model
                            regen()
                        }
                    }
                } label: {
                    Text(provider.name)
                }
            }
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        } primaryAction: {
            regen()
        }
        .menuStyle(HoverScaleMenuStyle())
        #else
        Button {
            regen()
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
        #endif
    }
    
    private func regen() {
        Task {
            await message.chat?.regenerate(message: message)
        }
    }
}

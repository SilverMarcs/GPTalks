//
//  ModelSwitchButtons.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2024.
//

import SwiftUI

struct ModelSwitchButtons: View {
    @Bindable var chat: Chat
    
    var body: some View {
        HStack {
            Button(action: {
                switchToPreviousModel()
            }) {
                Image(systemName: "chevron.left")
                    .padding()
            }
            .disabled(!hasPreviousModel())
            .keyboardShortcut(",", modifiers: [.shift, .command])
            
            Button(action: {
                switchToNextModel()
            }) {
                Image(systemName: "chevron.right")
                    .padding()
            }
            .disabled(!hasNextModel())
            .keyboardShortcut(".", modifiers: [.shift, .command])
        }
    }
    
    private var enabledModels: [ChatModel] {
        return chat.config.provider.chatModels.filter { $0.isEnabled }
    }
    
    private func getCurrentModelIndex() -> Int {
        return enabledModels.firstIndex(of: chat.config.model) ?? 0
    }
    
    private func hasPreviousModel() -> Bool {
        return getCurrentModelIndex() > 0
    }
    
    private func hasNextModel() -> Bool {
        return getCurrentModelIndex() < enabledModels.count - 1
    }
    
    private func switchToPreviousModel() {
        let currentIndex = getCurrentModelIndex()
        if currentIndex > 0 {
            chat.config.model = enabledModels[currentIndex - 1]
        }
    }
    
    private func switchToNextModel() {
        let currentIndex = getCurrentModelIndex()
        if currentIndex < enabledModels.count - 1 {
            chat.config.model = enabledModels[currentIndex + 1]
        }
    }
}

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
    
    private func getCurrentModelIndex() -> Int {
        return chat.config.provider.chatModels.firstIndex(of: chat.config.model) ?? 0
    }
    
    private func hasPreviousModel() -> Bool {
        return getCurrentModelIndex() > 0
    }
    
    private func hasNextModel() -> Bool {
        return getCurrentModelIndex() < chat.config.provider.chatModels.count - 1
    }
    
    private func switchToPreviousModel() {
        let currentIndex = getCurrentModelIndex()
        if currentIndex > 0 {
            chat.config.model = chat.config.provider.chatModels[currentIndex - 1]
        }
    }
    
    private func switchToNextModel() {
        let currentIndex = getCurrentModelIndex()
        if currentIndex < chat.config.provider.chatModels.count - 1 {
            chat.config.model = chat.config.provider.chatModels[currentIndex + 1]
        }
    }
}

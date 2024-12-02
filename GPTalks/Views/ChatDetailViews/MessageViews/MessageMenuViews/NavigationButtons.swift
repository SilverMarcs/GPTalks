//
//  NavigationButtons.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct NavigationButtons: View {
    var message: MessageGroup
    
    var body: some View {
        if message.allMessages.count > 1 {
            if message.allMessages.count >= 2 && message.role == .assistant {
                Button {
                    message.toggleSplitView()
                } label: {
                    Label(message.isSplitView ? "Exit SplitView" : "SplitView", systemImage: message.isSplitView ? "rectangle.split.2x1.slash" : "square.split.2x1")
                }
            }
            
            if !message.isSplitView {
                Button {
                    message.goToPreviousMessage()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(!message.canGoToPrevious)
                .opacity(message.canGoToPrevious ? 1 : 0.5)
                
                Text("\(message.currentMessageIndex + 1)/\(message.allMessages.count)")
                    .foregroundStyle(.secondary)
                    
                Button {
                    message.goToNextMessage()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(!message.canGoToNext)
                .opacity(message.canGoToNext ? 1 : 0.5)
            }
        }
    }
}

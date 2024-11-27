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
            if message.allMessages.count >= 2 {
                Button {
                    message.toggleSplitView()
                } label: {
                    Label(message.isSplitView ? "Exit Splitview" : "Splitview", systemImage: message.isSplitView ? "rectangle.split.2x1.slash" : "square.split.2x1")
                }
            }
            
            if !message.isSplitView {
                Button {
                    message.goToPreviousMessage()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(!message.canGoToPrevious)
//                .opacity(message.canGoToPrevious ? 1 : 0.5)
                
                Button {
                    message.goToNextMessage()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(!message.canGoToNext)
//                .opacity(message.canGoToNext ? 1 : 0.5)
            }
        }
    }
}

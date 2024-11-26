//
//  AssistantMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct AssistantMessage: View {
    @Bindable var message: MessageGroup
    
    @State private var showingTextSelection = false
    
    var body: some View {
        #if os(macOS)
        HStack {
            AssistantMessageAux(message: message.activeMessage, group: message)
            
            if message.isSplitView {
                Divider()
                
                AssistantMessageAux(message: message.secondaryMessages[message.secondaryMessageIndex],
                                    group: message, showMenu: false)
            }
        }
        #else
        AssistantMessageAux(message: message.activeMessage, group: message)
            .contextMenu {
                if !message.isReplying {
                    MessageMenu(message: self.message, isExpanded: .constant(true), toggleTextSelection: toggleTextSelection)
                }
            }
            .sheet(isPresented: $showingTextSelection) {
                TextSelectionView(content: message.content)
            }
        #endif
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantGroup)
        .frame(width: 500, height: 300)
}

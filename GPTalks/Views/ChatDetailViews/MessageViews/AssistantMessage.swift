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
        if message.isSplitView {
            HStack {
                AssistantMessageAux(message: message.activeMessage, group: message)
                
                Divider()
                    
                AssistantMessageAux(message: message.secondaryMessages[message.secondaryMessageIndex],
                                        group: message, showMenu: false)
            }
        } else {
            AssistantMessageAux(message: message.activeMessage, group: message)
        }
        #else
        AssistantMessageAux(message: message.activeMessage, group: message)
        #endif
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantGroup)
        .frame(width: 500, height: 300)
}

//
//  AssistantMessageAux.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct AssistantMessageAux: View {
    var message: MessageGroup
    
    var body: some View {
        #if os(macOS)
        if message.isSplitView {
            HStack {
                AssistantMessage(message: message.activeMessage, group: message)
                
                Divider()
                    
                AssistantMessage(message: message.secondaryMessages[message.secondaryMessageIndex],
                                        group: message, showMenu: false)
            }
        } else {
            AssistantMessage(message: message.activeMessage, group: message)
        }
        #else
        AssistantMessage(message: message.activeMessage, group: message)
        #endif
    }
}

#Preview {
    AssistantMessageAux(message: .mockAssistantGroup)
        .frame(width: 500, height: 300)
}

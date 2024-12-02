//
//  MessageMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct MessageMenu: View {
    var message: MessageGroup
    var toggleTextSelection: (() -> Void)? = nil

    var body: some View {
        Section {
            if message.role == .user {
                EditButton(setupEditing: { message.chat?.inputManager.setupEditing(message: message) })
            }
            
            if !message.isSplitView {
                 RegenButton(regenerate: { Task { await message.chat?.regenerate(message: message) } })
             }
        }
        
        CopyButton(content: message.content, dataFiles: message.dataFiles)

        Section {
            #if !os(macOS)
            if let toggleTextSelection = toggleTextSelection {
                SelectTextButton(toggleTextSelection: toggleTextSelection)
            }
            #endif
            
            ForkButton(copyChat: { await message.chat?.copy(from: message.activeMessage, purpose: .chat) })
        }
        
        Section {
            ResetContextButton(resetContext: { message.chat?.resetContext(at: message) })
            if message.chat?.currentThread.last == message {
                DeleteButton(deleteLastMessage: { message.chat?.deleteLastMessage() })
            }
        }
        
        #if os(macOS)
//        Divider()
        
        Section {
            NavigationButtons(message: message)
        }
        #endif
    }
}

#Preview {
    VStack {
        MessageMenu(message: .mockUserGroup)
        MessageMenu(message: .mockAssistantGroup)
    }
    .frame(width: 500)
    .padding()
}

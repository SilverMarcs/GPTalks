//
//  MessageMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct MessageMenu: View {
    var message: MessageGroup
    @Binding var isExpanded: Bool
    var toggleTextSelection: (() -> Void)? = nil

    var body: some View {
        ExpandButton(isExpanded: $isExpanded, message: message)
        
        Section {
            EditButton(message: message)
            RegenButton(message: message)
        }
    
        Section {
            CopyButton(message: message)
            ForkButton(message: message)
            #if !os(macOS)
            SelectTextButton(toggleTextSelection: toggleTextSelection)
            #endif
        }
        
        Section {
            ResetContextButton(message: message)
            DeleteButton(message: message)
        }
        
        #if os(macOS)
        Section {
            NavigationButtons(message: message)
        }
        #endif
    }
}

#Preview {
    VStack {
        MessageMenu(message: .mockUserGroup, isExpanded: .constant(true))
        MessageMenu(message: .mockAssistantGroup, isExpanded: .constant(true))
    }
    .frame(width: 500)
    .padding()
}

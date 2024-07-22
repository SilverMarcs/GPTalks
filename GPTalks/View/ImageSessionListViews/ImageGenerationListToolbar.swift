//
//  ImageGenerationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 20/07/2024.
//

import SwiftUI

struct ImageGenerationListToolbar: ToolbarContent {
    var session: ImageSession
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {

            } label: {
                Image(systemName: "slider.vertical.3")
            }
            .menuIndicator(.hidden)
        }
        
        ToolbarItemGroup(placement: .keyboard) {
            sendMessage
            deleteLastGeneration
        }
    }
    
    private var sendMessage: some View {
        Button("Send") {
            Task {
                await session.send()
            }
        }
        .keyboardShortcut(.return, modifiers: .command)
    }
    
    private var deleteLastGeneration: some View {
        Button("Delete Last Message") {
            if let last = session.imageGenerations.last {
                last.deleteSelf()
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
    }
}

//#Preview {
//    ImageGenerationListToolbar()
//}

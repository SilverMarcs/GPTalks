//
//  ImageCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ImageCommands: Commands {
    @Environment(ImageSessionVM.self) var sessionVM
    
    var body: some Commands {
        CommandMenu("Image") {
            Button("Send Prompt") {
                sessionVM.sendImageGenerationRequest()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(sessionVM.activeImageSession == nil)
            
            Button("Delete Last Generation") {
                sessionVM.deleteLastImageGeneration()
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .disabled(sessionVM.activeImageSession == nil)
        }
    }
}

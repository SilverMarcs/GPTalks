//
//  PanelTextEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/05/2024.
//

import SwiftUI

#if os(macOS)
struct PanelTextEditor: View {
    @Environment(DialogueViewModel.self) private var viewModel
    @State var prompt: String = ""
    
    let dismiss: () -> Void
    
    var body: some View {
        HStack {
            TextEditor(text: $prompt)
                .font(.system(size: 18))
                .scrollContentBackground(.hidden)
                
            SendButton(size: 26) {
                dismiss()
                NSApp.activate(ignoringOtherApps: true)
                
                let session = viewModel.addFloatingDialogue()
                session?.input = prompt

                Task { @MainActor in
                    await session?.send()
                }
                
                prompt = ""
            }
            .buttonStyle(.plain)
        }
        .padding(10)
    }
}
#endif

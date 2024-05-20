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
            TextField("Ask AI", text: $prompt)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
                
            SendButton(size: 28) {
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
        .padding()
        .padding(.horizontal, 3)
        .padding(.bottom, -28)
    }
}
#endif

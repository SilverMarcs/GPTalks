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
        HStack(spacing: 12) {
            Button {
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            TextField("Ask AI...", text: $prompt)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
                
            SendButton2(size: 28) {
                dismiss()
                NSApp.activate(ignoringOtherApps: true)
                NSApp.keyWindow?.makeKeyAndOrderFront(nil)
                
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
        .padding(.leading, 3)
        .padding(.bottom, -30)
    }
}
#endif

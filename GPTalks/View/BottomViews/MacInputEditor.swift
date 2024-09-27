//
//  MacInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

#if os(macOS)
import SwiftUI

struct MacInputEditor: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if prompt.isEmpty {
                Text(placeHolder)
                    .padding(6)
                    .padding(.leading, 6)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
                .padding(6)
        }
        .font(.body)
        .modifier(RoundedRectangleOverlayModifier(radius: 18))
        .onChange(of: sessionVM.chatSelections) {
            isFocused = true
        }
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
    
    var leadingPadding: CGFloat {
        return 0
    }
}
#endif

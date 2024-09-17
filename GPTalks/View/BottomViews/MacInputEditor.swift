//
//  MacInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

#if os(macOS)
import SwiftUI

struct MacInputEditor: View {
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
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = true
                    AppConfig.shared.sidebarFocus = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }
        .task {
            if !AppConfig.shared.sidebarFocus {
                isFocused = true
            }
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

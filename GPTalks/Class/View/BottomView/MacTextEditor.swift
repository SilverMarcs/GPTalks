//
//  MacTextEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI

#if os(macOS)
struct MacTextEditor: View {
    @Binding var input: String
    @FocusState var focused: Bool
    
    var body: some View {
        ZStack(alignment: .leading){
            if input.isEmpty {
                Text("Send a message")
                    .font(.body)
                    .padding(6)
                    .padding(.leading, 6)
                    .foregroundColor(Color(.placeholderTextColor))
            }
            
            TextEditor(text: $input)
                .focused($focused)
                .font(.body)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .padding(6)
//                .padding(.trailing, 15) // for avoiding send button
                .scrollContentBackground(.hidden)
                .onAppear {
                    DispatchQueue.main.async {
                        focused = true
                    }
                }
            
        
            Button("hidden") {
                focused = true
            }
            .keyboardShortcut("l", modifiers: .command)
            .hidden()
        }
//        .roundedRectangleOverlay()
    }
}
#endif

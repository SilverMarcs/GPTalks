//
//  iOSInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI


struct iOSInputEditor: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    @State private var showPopover: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField(placeHolder, text: $prompt, axis: .vertical)
                .focused($isFocused)
                .padding(6)
                .padding(.leading, 5)
                .lineLimit(10)
                .modifier(RoundedRectangleOverlayModifier(radius: 18))

            if prompt.count > 25 {
                ExpandButton(size: 25) { showPopover.toggle() }
                    .padding(5)
                    .sheet(isPresented: $showPopover) {
                        ExpandedTextField(prompt: $prompt)
                    }
            }
        }
//        .task {
//            if let session = sessionVM.activeSession {
//                isFocused = true
//            }
//        }
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
    
    var leadingPadding: CGFloat {
        return 10
    }
}

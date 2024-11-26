//
//  ImageInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ImageInputView: View {
    @Bindable var session: ImageSession
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            TextField("Prompt", text: $session.prompt, axis: .vertical)
                .onSubmit( { sendInput() } )
                .textFieldStyle(.plain)
                .padding(.leading, 8)
                .focused($isFocused, equals: .imageInput)
            
            Button(action: sendInput) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title).fontWeight(.semibold)
            }
            .foregroundStyle(.white, .accent)
            .buttonStyle(.plain)
        }
        .padding(2)
        .roundedRectangleOverlay()
        .modifier(CommonInputStyling())
        #if os(macOS)
        .task {
            isFocused = .imageInput
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Focus") {
                    isFocused = .imageInput
                }
                .keyboardShortcut("l")
            }
        }
        #endif
    }
    
    private func sendInput() {
        guard !session.prompt.isEmpty else { return }
        
        #if !os(macOS)
        isFocused = nil
        #endif
        Task { @MainActor in
            await session.send()
        }
    }
    
    var imageSize: CGFloat {
        #if os(macOS)
        21
        #else
        31
        #endif
    }
}

#Preview {
    ImageInputView(session: .mockImageSession)
}

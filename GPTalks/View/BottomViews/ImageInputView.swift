//
//  ImageInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ImageInputView: View {
    @Bindable var session: ImageSession
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            InputEditor(prompt: $session.prompt,
                        provider: session.config.provider,
                        isFocused: _isFocused)
            
            ActionButton(size: imageSize, isStop: false) {
                sendInput()
            }
        }
        .padding(5)
        .roundedRectangleOverlay(radius: 20)
        .modifier(CommonInputStyling())
    }
    
    private func sendInput() {
        #if !os(macOS)
        isFocused = false
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

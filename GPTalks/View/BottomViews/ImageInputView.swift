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
        HStack(alignment: .bottom, spacing: 15) {
            InputEditor(prompt: $session.prompt,
                        provider: session.config.provider,
                        isFocused: _isFocused)
            
            SendButton(size: imageSize, send: sendInput)
                .offset(y: -2.4)
        }
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
      #if os(macOS) || targetEnvironment(macCatalyst)
        23
        #else
        30
        #endif
    }
}

//#Preview {
//    ImageInputView()
//}

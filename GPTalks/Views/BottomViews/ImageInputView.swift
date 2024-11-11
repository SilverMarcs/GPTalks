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
            TextField("Prompt", text: $session.prompt)
                .focused($isFocused, equals: .imageInput)
                .onSubmit( { sendInput() } )
                .textFieldStyle(.plain)
                .padding(.leading, 5)
            
            Button(action: sendInput) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white, .accent)
            .buttonStyle(.plain)
        }
        .padding(5)
        .roundedRectangleOverlay(radius: 20)
        .modifier(CommonInputStyling())
        #if os(macOS)
        .onAppear {
            isFocused = .imageInput
        }
        #endif
    }
    
    private func sendInput() {
        guard !session.prompt.isEmpty else { return }
        
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

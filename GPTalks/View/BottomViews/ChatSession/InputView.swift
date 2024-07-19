//
//  InputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import VisualEffectView

struct InputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var session: Session
    
    @State var isPresented: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if session.inputManager.state == .editing {
                CrossButton(size: imageSize) { session.inputManager.resetEditing() }
                    .offset(y: -2.4)
            }
            
            plusButton
#if os(macOS)
                .offset(y: -2.4)
#endif
            
            VStack(alignment: .leading) {
                if !session.inputManager.imagePaths.isEmpty {
                    InputImageView(session: session)
                }
                
                InputEditor(prompt: $session.inputManager.prompt,
                            isFocused: _isFocused)
            }
            
            if session.isReplying {
                StopButton(size: imageSize, stop: session.stopStreaming)
                    .offset(y: -2.4)
            } else {
                SendButton(size: imageSize, send: sendInput)
                    .offset(y: -2.4)
            }
        }
        .modifier(CommonInputStyling())
    }
    
    var plusButton: some View {
        Group {
#if os(macOS)
        PlusButton(size: imageSize) {
            isPresented = true
        }
#else
        PlusImage()
            .gesture(
                TapGesture()
                    .onEnded {
                        isPresented = true
                    }
                    .simultaneously(with: LongPressGesture(minimumDuration: 0.3).onEnded { _ in
                        if let lastGroup = session.groups.last {
                            session.resetContext(at: lastGroup)
                        }
                    })
            )
#endif
        }
        .imageFileImporter(isPresented: $isPresented, onImageAppend: { image in
            if let path = image.save() {
                session.inputManager.imagePaths.append(path)
            }
        })
    }
    
    var verticalPadding: CGFloat {
#if os(macOS)
        14
#else
        9
#endif
    }
    
    var imageSize: CGFloat {
      #if os(macOS)
        23
        #else
        30
        #endif
    }
    
    private func sendInput() {
        isFocused = false
        Task { @MainActor in
            await session.sendInput()
        }
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    
    session.inputManager.prompt = "Hello, World"
    
    return InputView(session: session)
        .padding()
}

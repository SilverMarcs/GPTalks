//
//  InputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct InputView: View {
    @Bindable var session: Session
    
    @State var isPresented: Bool = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if session.inputManager.state == .editing {
                CrossButton(size: imageSize) { session.inputManager.resetEditing() }
                    .offset(y: -2.4)
            }
            
            PlusButton(size: imageSize) {
                isPresented = true
            }
            .offset(y: -2.4)
            .imageFileImporter(isPresented: $isPresented, onImageAppend: { image in
                if let path = image.save() {
                    session.inputManager.imagePaths.append(path)
                }
            })
            
            VStack(alignment: .leading) {
                if !session.inputManager.imagePaths.isEmpty {
                    InputImageView(session: session)
                }
                
                InputEditor(prompt: $session.inputManager.prompt)
            }
            
            if session.isReplying {
                StopButton(size: imageSize, stop: session.stopStreaming)
                    .offset(y: -2.4)
            } else {
                SendButton(size: imageSize, send: sendInput)
                    .offset(y: -2.4)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(.bar)
        .ignoresSafeArea()
    }
    
    var imageSize: CGFloat = 23
    
    private func sendInput() {
        Task { @MainActor in
            await session.sendInput()
        }
    }
}

#Preview {
    let session = Session()
    session.inputManager.prompt = "Hello, World"
    
    return InputView(session: session)
        .padding()
}

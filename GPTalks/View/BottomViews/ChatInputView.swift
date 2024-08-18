//
//  ChatInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import VisualEffectView

struct ChatInputView: View {
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
                if !session.inputManager.dataFiles.isEmpty {
                    DataFileView(dataFiles: $session.inputManager.dataFiles, isCrossable: true)
                }
                
                InputEditor(prompt: $session.inputManager.prompt,
                            isFocused: _isFocused)
            }

            ActionButton(size: imageSize, isStop: session.isReplying) {
                if session.isReplying {
                    session.stopStreaming()
                } else {
                    sendInput()
                }
            }
            .offset(y: -2.4)
        }
        .modifier(CommonInputStyling())
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Paste Image") {
                    session.inputManager.handlePaste()
                }
                .keyboardShortcut("b")
            }
        }
        #endif
    }

    var plusButton: some View {
        Group {
#if os(macOS)
            PlusButton(size: imageSize) {
                isPresented = true
            }
#else
            
            Menu {
                Button(action: resetContext) {
                    Label("Reset Context", systemImage: "eraser")
                }
            } label: {
                PlusImage()
            } primaryAction: {
                isPresented = true
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .accentColor(.primary)
#endif
        }
        .multipleFileImporter(isPresented: $isPresented, supportedFileTypes: session.config.provider.type.supportedFileTypes) { typedData in
            session.inputManager.dataFiles.append(typedData)
        }
    }
    
    func resetContext() {
        if let lastGroup = session.groups.last {
            session.resetContext(at: lastGroup)
        }
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
        #if !os(macOS)
        isFocused = false
        #endif
        Task { @MainActor in
            await session.sendInput()
        }
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    
    session.inputManager.prompt = "Hello, World"
    
    return ChatInputView(session: session)
        .padding()
}

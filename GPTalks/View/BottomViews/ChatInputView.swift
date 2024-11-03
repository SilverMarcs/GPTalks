//
//  ChatInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ChatInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var session: ChatSession
    
    @State private var isFilePickerPresented: Bool = false

    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if session.inputManager.state == .editing {
                CrossButton(size: imageSize) { session.inputManager.resetEditing() }
            }
            
            plusButton
            
            VStack(alignment: .leading, spacing: 8) {
                if !session.inputManager.dataFiles.isEmpty {
                    DataFileView(dataFiles: $session.inputManager.dataFiles, isCrossable: true, edge: .leading)
                }
                
                InputEditor(prompt: $session.inputManager.prompt,
                            provider: session.config.provider, isFocused: _isFocused)
                .padding(.vertical, -2)
            }

            ActionButton(size: imageSize, isStop: session.isReplying) {
                if session.isReplying {
                    session.stopStreaming()
                } else {
                    sendInput()
                }
            }
        }
        .padding(.vertical, 1)
    }

    var plusButton: some View {
        Group {
            #if os(macOS)
            macosPlus
            #else
            iosPlus
            #endif
        }
        .multipleFileImporter(isPresented: $isFilePickerPresented, inputManager: session.inputManager)
    }
    
    var macosPlus: some View {
        PlusButton(size: imageSize) {
            isFilePickerPresented = true
        }
    }
    
    #if !os(macOS)
    var iosPlus: some View {
        Menu {
            Button(action: resetContext) {
                Label("Reset Context", systemImage: "eraser")
            }
            
            Button {
                session.showCamera.toggle()
            } label: {
                Label("Open Camera", systemImage: "camera")
            }
            
            Button {
                isFilePickerPresented = true
            } label: {
                Label("Add Files", systemImage: "doc")
            }
        } label: {
            PlusImage()
        } primaryAction: {
            showPhotosPicker = true
        }
        .popoverTip(PlusButtonTip())
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .accentColor(.primary)
        .fullScreenCover(isPresented: $session.showCamera) {
            CameraView { typedData in
                session.inputManager.dataFiles.append(typedData)
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images, photoLibrary: .shared())
        .onChange(of: selectedPhotos) {
            Task {
                await session.inputManager.loadTransferredPhotos(from: selectedPhotos)
                DispatchQueue.main.async {
                    selectedPhotos.removeAll()
                }
            }
        }
    }
    #endif
    
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
    ChatInputView(session: .mockChatSession)
        .padding()
}

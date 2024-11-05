//
//  ChatInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import SwiftData

struct ChatInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var session: ChatSession
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if session.inputManager.state == .editing {
                HStack(spacing: 5) {
                    CrossButton {
                        session.inputManager.resetEditing()
                    }
                    
                    Text("Editing")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 5)
                .padding(5)
                
                Divider()
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                plusButton
                    .padding(.trailing, -3)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 0)
                    
                    if !session.inputManager.dataFiles.isEmpty {
                        DataFileView(dataFiles: $session.inputManager.dataFiles, isCrossable: true, edge: .leading)
                            .padding(.bottom, 5)
                    }
                    
                    InputEditor(prompt: $session.inputManager.prompt, provider: session.config.provider, isFocused: _isFocused)
                    
                    Spacer(minLength: 0)
                }
                
                ActionButton(size: imageSize, isStop: session.isReplying) {
                    session.isReplying ? session.stopStreaming() : sendInput()
                }
            }
            .padding(6)
        }
        .roundedRectangleOverlay(radius: 18)
        .modifier(CommonInputStyling())
    }

    var plusButton: some View {
        Menu {
            #if !os(macOS)
            Button(action: {session.showCamera = true}) {
                Label("Open Camera", systemImage: "camera")
            }
            #endif
            
            Button(action: { isFilePickerPresented = true }) {
                Label("Attach Files", systemImage: "paperclip")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .foregroundStyle(.primary, .clear)
                .frame(width: imageSize, height: imageSize)
            
        } primaryAction: {
            showPhotosPicker = true
        }
        .popoverTip(PlusButtonTip())
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .multipleFileImporter(isPresented: $isFilePickerPresented, inputManager: session.inputManager)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            await session.inputManager.loadTransferredPhotos(from: selectedPhotos)
            selectedPhotos.removeAll()
        }
        #if !os(macOS)
        .fullScreenCover(isPresented: $session.showCamera) {
            CameraView(session: session)
                .ignoresSafeArea()
        }
        #endif
    }
    
    var imageSize: CGFloat {
        #if os(macOS)
        23
        #else
        31
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
    ConversationList(session: .mockChatSession)
        .environment(ChatSessionVM(modelContext: try! ModelContainer(for: ChatSession.self).mainContext))
}

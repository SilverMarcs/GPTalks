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
    @Bindable var chat: Chat
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if chat.inputManager.state == .editing {
                cancelEditing
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                plusButton
                    .padding(.trailing, -3)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 0)
                    
                    if !chat.inputManager.dataFiles.isEmpty {
                        DataFilesView(dataFiles: $chat.inputManager.dataFiles, isCrossable: true, edge: .leading)
                            .padding(.bottom, 5)
                    }
                    
                    InputEditor(prompt: $chat.inputManager.prompt, provider: chat.config.provider, isFocused: _isFocused)
                    
                    Spacer(minLength: 0)
                }
                
                ActionButton(size: imageSize, isStop: chat.isReplying) {
                    chat.isReplying ? chat.stopStreaming() : sendInput()
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
            Button(action: {chat.showCamera = true}) {
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
        .multipleFileImporter(isPresented: $isFilePickerPresented, inputManager: chat.inputManager)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            await chat.inputManager.loadTransferredPhotos(from: selectedPhotos)
            selectedPhotos.removeAll()
        }
        #if !os(macOS)
        .fullScreenCover(isPresented: $chat.showCamera) {
            CameraView(chat: chat)
                .ignoresSafeArea()
        }
        #endif
    }
    
    @ViewBuilder
    var cancelEditing: some View {
        HStack(spacing: 5) {
            Button {
                chat.inputManager.reset()
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .keyboardShortcut(.cancelAction)
            .buttonStyle(.plain)
            
            Text("Editing")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 5)
        .padding(5)
        
        Divider()
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
            await chat.sendInput()
        }
    }
}

#Preview {
    ThreadList(chat: .mockChat)
        .environment(ChatVM(modelContext: try! ModelContainer(for: Chat.self).mainContext))
}

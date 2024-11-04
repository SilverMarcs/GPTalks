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
        HStack(alignment: .bottom, spacing: 0) {
            if session.inputManager.state == .editing {
                CrossButton(size: imageSize) { session.inputManager.resetEditing() }
            }
            
            plusButton
                .padding(6)
                .padding(.trailing, -6)
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer(minLength: 0)
                
                if !session.inputManager.dataFiles.isEmpty {
                    DataFileView(dataFiles: $session.inputManager.dataFiles, isCrossable: true, edge: .leading)
                }
                
                InputEditor(prompt: $session.inputManager.prompt,
                            provider: session.config.provider, isFocused: _isFocused)
                
                Spacer(minLength: 0)
            }

            ActionButton(size: imageSize, isStop: session.isReplying) {
                if session.isReplying {
                    session.stopStreaming()
                } else {
                    sendInput()
                }
            }
            .padding(6)
        }
        .modifier(RoundedRectangleOverlayModifier(radius: 20))
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
            Button {
                session.showCamera = true
            } label: {
                Label("Open Camera", systemImage: "camera")
            }
            
            Button {
                isFilePickerPresented = true
            } label: {
                Label("Add Files", systemImage: "doc")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: imageSize + 1, height: imageSize + 1)
                .foregroundStyle(.secondary, .clear)
                .buttonStyle(.plain)
                
        } primaryAction: {
            showPhotosPicker = true
        }
        .popoverTip(PlusButtonTip())
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .accentColor(.primary)
        .fullScreenCover(isPresented: $session.showCamera) {
            CameraView(session: session)
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
//    ChatInputView(session: .mockChatSession)
    ConversationList(session: .mockChatSession)
        .environment(ChatSessionVM(modelContext: try! ModelContainer(for: ChatSession.self).mainContext))
//        .padding()
}

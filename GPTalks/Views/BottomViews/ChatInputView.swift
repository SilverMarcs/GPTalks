//
//  ChatInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import TipKit

struct ChatInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var chat: Chat
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
    @FocusState private var isFocused: FocusedField?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack {
                if chat.inputManager.state == .editing {
                    cancelEditing
                    
                    Spacer()
                }
                
                plusButton
                    .padding(.trailing, -3)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                #if os(macOS)
                TipView(PlusButtonTip())
                    .frame(height: 30)
                    .padding(.bottom, 15)
                #endif

                Spacer(minLength: 0)
                
                if !chat.inputManager.dataFiles.isEmpty {
                    DataFilesView(dataFiles: chat.inputManager.dataFiles, edge: .leading) { file in
                        withAnimation {
                            chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                InputEditor(chat: chat)
                
                Spacer(minLength: 0)
            }
            
            ActionButton(isStop: chat.isReplying) {
                chat.isReplying ? chat.stopStreaming() : sendInput()
            }
        }
        .modifier(CommonInputStyling())
    }

    var plusButton: some View {
        Menu {
            #if !os(macOS)
            Button {
                chat.showCamera = true
                PlusButtonTip().invalidate(reason: .actionPerformed)
            } label: {
                Label("Open Camera", systemImage: "camera")
            }
            #endif
            
            Button {
                isFilePickerPresented = true
                PlusButtonTip().invalidate(reason: .actionPerformed)
            } label: {
                Label("Attach Files", systemImage: "paperclip")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title).fontWeight(.semibold)
                .foregroundStyle(.primary, .clear)
            
        } primaryAction: {
            showPhotosPicker = true
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            await chat.inputManager.loadTransferredPhotos(from: selectedPhotos)
            selectedPhotos.removeAll()
        }
        
        #if !os(macOS)
        .popoverTip(PlusButtonTip())
        .fullScreenCover(isPresented: $chat.showCamera) {
            CameraView(chat: chat)
                .ignoresSafeArea()
        }
        #endif
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task {
                    for url in urls {
                        // TODO: MOVE SEC STUFF TO PROCESSFILE FUNC
                        guard url.startAccessingSecurityScopedResource() else {
                            print("Failed to access security scoped resource for: \(url.lastPathComponent)")
                            continue
                        }
                        
                        do {
                            try await chat.inputManager.processFile(at: url)
                        } catch {
                            print("Failed to process file: \(url.lastPathComponent). Error: \(error)")
                        }
                        
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
    
    var cancelEditing: some View {
        Button {
            withAnimation {
                chat.inputManager.reset()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title).fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .keyboardShortcut(.cancelAction)
        .buttonStyle(.plain)
    }
    
    private func sendInput() {
        #if !os(macOS)
        isFocused = nil
        #endif
        Task { @MainActor in
            await chat.sendInput()
        }
    }
}

import SwiftData
#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM())
}

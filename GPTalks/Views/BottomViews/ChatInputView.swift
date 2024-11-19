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
    @ObservedObject var config = AppConfig.shared
    
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
            Group {
                #if !os(macOS)
                Button {
                    config.showCamera = true
                } label: {
                    Label("Open Camera", systemImage: "camera")
                }
                #endif
                
                Button {
                    showPhotosPicker = true
                } label: {
                    Label("Photos Library", systemImage: "photo.on.rectangle.angled")
                }
                
                Button {
                    isFilePickerPresented = true
                } label: {
                    Label(
                        "Attach Files", systemImage: "paperclip")
                }
            }
            .labelStyle(.titleAndIcon)
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title).fontWeight(.semibold)
                .foregroundStyle(.primary, .clear)
            
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
        .fullScreenCover(isPresented: $config.showCamera) {
            CameraView(chat: chat)
                .ignoresSafeArea()
        }
        #else
        .popoverTip(PlusButtonTip())
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

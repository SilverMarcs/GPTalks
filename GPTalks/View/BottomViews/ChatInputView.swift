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
    @Bindable var session: Session
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
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
                .popoverTip(ChatCommandsTip())
            #endif
            
            VStack(alignment: .leading, spacing: 5) {
                if !session.inputManager.dataFiles.isEmpty {
                    DataFileView(dataFiles: $session.inputManager.dataFiles, isCrossable: true, edge: .leading)
                }
                
                InputEditor(prompt: $session.inputManager.prompt,
                            provider: session.config.provider, isFocused: _isFocused)
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
    }

    var plusButton: some View {
        #if os(macOS)
        macosPlus
        #else
        iosPlus
        #endif
    }
    
    var macosPlus: some View {
        PlusButton(size: imageSize) {
            isFilePickerPresented = true
        }
        .multipleFileImporter(isPresented: $isFilePickerPresented, supportedFileTypes: session.config.provider.type.supportedFileTypes) { typedData in
            session.inputManager.dataFiles.append(typedData)
        }
    }
    
    #if !os(macOS)
    var iosPlus: some View {
        Menu {
            Button(action: resetContext) {
                Label("Reset Context", systemImage: "eraser")
            }
            
            Button {
                self.showCamera.toggle()
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
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { typedData in
                session.inputManager.dataFiles.append(typedData)
            }
            .ignoresSafeArea()
        }
        .multipleFileImporter(isPresented:  $isFilePickerPresented, supportedFileTypes: session.config.provider.type.supportedFileTypes) { typedData in
            session.inputManager.dataFiles.append(typedData)
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images, photoLibrary: .shared())
        .onChange(of: selectedPhotos) {
            Task {
                await loadTransferredPhotos(from: selectedPhotos)
                DispatchQueue.main.async {
                    selectedPhotos.removeAll()
                }
            }
        }
    }
    #endif
    
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
        Task {
            await session.sendInput()
        }
    }
    
    private func loadTransferredPhotos(from selectedPhotos: [PhotosPickerItem]) async {
        for photo in selectedPhotos {
            if let data = try? await photo.loadTransferable(type: Data.self) {
                let fileName = "photo_\(UUID().uuidString)"
                let fileExtension = "jpg"
                let fileSize = data.count.formatFileSize()
                
                let typedData = TypedData(
                    data: data,
                    fileType: .image,
                    fileName: fileName,
                    fileSize: fileSize,
                    fileExtension: fileExtension
                )
                
                DispatchQueue.main.async {
                    session.inputManager.dataFiles.append(typedData)
                }
            }
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

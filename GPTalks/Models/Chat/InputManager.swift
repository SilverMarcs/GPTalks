//
//  InputManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

@Observable class InputManager {
    var state: InputState = .normal
    
    var normalPrompt: String = ""
    var editingPrompt: String = ""
    
    var tempNormalPrompt: String = ""
    var tempNormalDataFiles: [TypedData] = []
    
    var normalDataFiles: [TypedData] = []
    var editingDataFiles: [TypedData] = []
    
    var editingMessage: Message?
    
    var prompt: String {
        get { state == .normal ? normalPrompt : editingPrompt }
        set {
            if state == .normal {
                normalPrompt = newValue
            } else {
                editingPrompt = newValue
            }
        }
    }
    
    var dataFiles: [TypedData] {
        get { state == .normal ? normalDataFiles : editingDataFiles }
        set {
            if state == .normal {
                normalDataFiles = newValue
            } else {
                editingDataFiles = newValue
            }
        }
    }
    
    func setupEditing(message: MessageGroup) {
        Scroller.scroll(to: .top, of: message, animated: false)
        
        withAnimation {
            state = .editing
        }
        
        tempNormalPrompt = normalPrompt
        tempNormalDataFiles = normalDataFiles
        
        editingMessage = message.activeMessage
        prompt = message.content
        dataFiles = message.dataFiles
    }
    
    func reset() {
        state = .normal
        editingMessage = nil
        prompt = tempNormalPrompt
        dataFiles = tempNormalDataFiles
    }
}

// MARK: - Drag and Drop
extension InputManager {
    func processData(_ data: Data, fileType: UTType? = nil, fileName: String? = nil, url: URL? = nil) async throws {
            let fileURL = url ?? URL(fileURLWithPath: fileName ?? "Unknown")
            let fileType = fileType ?? (try? fileURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier).flatMap { UTType($0) } ?? .data
            let fileName = fileName ?? fileURL.deletingPathExtension().lastPathComponent + "." + fileType.fileExtension

            let typedData = TypedData(
                data: data,
                fileType: fileType,
                fileName: fileName
            )
        
        await MainActor.run {
            // Remove existing file with the same name, if any
            if let existingIndex = self.dataFiles.firstIndex(where: { $0.fileName == fileName }) {
                self.dataFiles.remove(at: existingIndex)
            }

            withAnimation {
                self.dataFiles.insert(typedData, at: 0)
            }
        }
    }
    
    func processFile(at url: URL) async throws {
        let data = try Data(contentsOf: url)
        try await processData(data, url: url)
    }
    
    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            // First, get the file name using loadFileRepresentation
            provider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, _ in
                guard let url = url else { return }
                
                let fileName = url.lastPathComponent
                
                // Now, use loadDataRepresentation to get the data and file type
                provider.loadDataRepresentation(forTypeIdentifier: UTType.item.identifier) { data, error in
                    guard let data = data else {
                        print("Failed to load data representation")
                        return
                    }
                    
                    Task {
                        do {
                            let fileType = provider.registeredTypeIdentifiers.first.flatMap { UTType($0) } ?? .data
                            try await self.processData(data, fileType: fileType, fileName: fileName)
                        } catch {
                            print("Failed to process file: \(fileName). Error: \(error)")
                        }
                    }
                }
            }
        }
        
        return !providers.isEmpty
    }
    
    func loadTransferredPhotos(from selectedPhotos: [PhotosPickerItem]) async {
        for photo in selectedPhotos {
            if let data = try? await photo.loadTransferable(type: Data.self) {
                let fileName = "photo_\(UUID().uuidString).jpg"
                
                do {
                    try await self.processData(data, fileType: .jpeg, fileName: fileName)
                } catch {
                    print("Failed to process photo: \(fileName). Error: \(error)")
                }
            }
        }
    }
}

// MARK: - Pasting
#if os(macOS)
extension InputManager {
    private static let supportedImageTypes: Set<UTType> = [.png, .tiff, .jpeg]

    func handlePaste(pasteboardItem: NSPasteboardItem) {
        Task {
            do {
                if let fileURLData = pasteboardItem.data(forType: .fileURL),
                   let fileURL = URL(dataRepresentation: fileURLData, relativeTo: nil) {
                    try await processFile(at: fileURL)
                } else if let imageData = pasteboardItem.data(forType: .png) ?? pasteboardItem.data(forType: .tiff) {
                    try await processData(imageData, fileType: .png, fileName: "Pasted_Image_\(UUID().uuidString).png")
                }
            } catch {
                print("Error processing paste: \(error)")
            }
        }
    }
}
#endif

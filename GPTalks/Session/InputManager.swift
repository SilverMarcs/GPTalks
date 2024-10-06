//
//  InputManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import UniformTypeIdentifiers

enum InputState {
    case normal
    case editing
}

@Observable class InputManager {
    var state: InputState = .normal
    
    var normalPrompt: String = ""
    var tempNormalPrompt: String? = ""
    
    var editingPrompt: String = ""
    var editingDataFiles: [TypedData] = []
    
    var editingIndex: Int?
    
    var normalDataFiles: [TypedData] = []
    var tempNormalDataFiles: [TypedData] = []
    
    init() { }
    
    var prompt: String {
        get {
            switch state {
            case .normal:
                normalPrompt
            case .editing:
                editingPrompt
            }
        }
        set {
            switch state {
            case .normal:
                normalPrompt = newValue
            case .editing:
                editingPrompt = newValue
            }
        }
    }
    
    var dataFiles: [TypedData] {
        get {
            switch state {
            case .normal:
                normalDataFiles
            case .editing:
                editingDataFiles
            }
        }
        set {
            switch state {
            case .normal:
                normalDataFiles = newValue
            case .editing:
                editingDataFiles = newValue
            }
        }
    }
    
    func setupEditing(for group: ConversationGroup) {
        tempNormalPrompt = normalPrompt
        tempNormalDataFiles = normalDataFiles
        
        state = .editing
        prompt = group.activeConversation.content

        dataFiles = group.activeConversation.dataFiles
        editingIndex = group.session?.groups.firstIndex(of: group)
    }
    
    func resetEditing() {
        state = .normal
        editingIndex = nil
        prompt = tempNormalPrompt ?? ""
    }
    
    func reset() {
        prompt = ""
        dataFiles = []
    }
}


// MARK: - Pasting
extension InputManager {
    func handlePaste(supportedFileTypes: [UTType]) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general

        guard let pasteboardItems = pasteboard.pasteboardItems else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            for item in pasteboardItems {
                if let fileURLData = item.data(forType: .fileURL),
                   let fileURL = URL(dataRepresentation: fileURLData, relativeTo: nil) {
                    self.processFile(at: fileURL, supportedFileTypes: supportedFileTypes)
                } else if let imageData = item.data(forType: .png) {
                    self.processImageData(imageData, supportedFileTypes: supportedFileTypes)
                }
            }
        }
        #endif
    }

    private func processFile(at url: URL, supportedFileTypes: [UTType]) {
        guard let fileUTType = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
              let fileType = UTType(fileUTType),
              supportedFileTypes.contains(where: { fileType.conforms(to: $0) }) else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            DispatchQueue.main.async {
                self.appendTypedData(data: data, url: url, fileType: fileType)
            }
        } catch {
            print("Failed to read file data: \(error)")
        }
    }

    func processImageData(_ imageData: Data, supportedFileTypes: [UTType]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")

            do {
                try imageData.write(to: tempFileURL)
                self.processFile(at: tempFileURL, supportedFileTypes: supportedFileTypes)
            } catch {
                print("Failed to write image data to temporary file: \(error)")
            }
        }
    }

    private func appendTypedData(data: Data, url: URL, fileType: UTType) {
        let fileName = url.deletingPathExtension().lastPathComponent
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = (attributes?[.size] as? Int ?? data.count).formatFileSize()
        let fileExtension = url.pathExtension.lowercased()

        let typedData = TypedData(
            data: data,
            fileType: fileType,
            fileName: fileName,
            fileSize: fileSize,
            fileExtension: fileExtension
        )

        dataFiles.append(typedData)
    }
}

// MARK: - Drag and Drop
extension InputManager {
    func handleDrop(_ providers: [NSItemProvider], supportedTypes: [UTType]) -> Bool {
        print("Handling drop with supported types: \(supportedTypes)")
        
        for provider in providers {
            for type in supportedTypes {
                if provider.hasItemConformingToTypeIdentifier(type.identifier) {
                    provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, error in
                        guard let url = url else {
                            if let error = error {
                                print("Error loading file representation: \(error.localizedDescription)")
                            }
                            return
                        }
                        
                        print("Processing dropped file: \(url.lastPathComponent)")
                        
                        DispatchQueue.main.async {
                            if let data = try? Data(contentsOf: url) {
                                let fileType = UTType(filenameExtension: url.pathExtension) ?? .data
                                let fileName = url.deletingPathExtension().lastPathComponent
                                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                                let fileSize = (attributes?[.size] as? Int ?? 0).formatFileSize()
                                let fileExtension = url.pathExtension.lowercased()
                                let typedData = TypedData(
                                    data: data,
                                    fileType: fileType,
                                    fileName: fileName,
                                    fileSize: fileSize,
                                    fileExtension: fileExtension
                                )
                                
                                self.dataFiles.append(typedData)
                                print("Added file to dataFiles array. Current count: \(self.dataFiles.count)")
                            } else {
                                print("Failed to read data from file: \(url.lastPathComponent)")
                            }
                        }
                    }
                    return true
                }
            }
        }
        
        print("No compatible files found in the drop")
        return false
    }
}
